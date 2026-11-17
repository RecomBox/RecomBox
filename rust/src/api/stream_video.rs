use axum::{
    body::Body,
    extract::Query,
    http::{header, HeaderMap, HeaderValue, StatusCode},
    response::{IntoResponse, Response},
};
use librqbit::TorrentStatsState;
use serde::{Deserialize, Serialize};
use std::io::SeekFrom;
use std::path::PathBuf;
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncSeekExt};
use tokio_util::io::ReaderStream;
use urlencoding::encode;

use crate::utils::settings::Settings;
use crate::utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode};

#[derive(Deserialize, Serialize)]
pub struct InputPayload {
    torrent_handle_mode: String,
    torrent_source: String,
    mime_type: String,
    file_id: usize,
    view_id: String,
    season: u64,
    episode: u64,
}

/// How long a request waits for a freshly added torrent to finish initializing
/// (metadata + checking existing pieces) before giving up.
const INIT_TIMEOUT: Duration = Duration::from_secs(120);
/// Read buffer size for the response body.
const CHUNK_SIZE: usize = 64 * 1024;

fn error(status: StatusCode, msg: impl ToString) -> Response {
    let msg = msg.to_string();
    eprintln!("[stream_video] {}: {}", status, msg);
    (status, msg).into_response()
}

enum RangeResult {
    /// No (usable) Range header → serve whole file with 200.
    Full,
    /// Valid satisfiable range (inclusive start, inclusive end).
    Partial(u64, u64),
    /// Range header present but cannot be satisfied → 416.
    Unsatisfiable,
}

/// Parses a single-range `Range: bytes=...` header.
/// Supports `a-b`, `a-` and suffix `-n`. Multi-range requests fall back to the first range.
fn parse_range(headers: &HeaderMap, total_len: u64) -> RangeResult {
    let Some(value) = headers.get(header::RANGE).and_then(|v| v.to_str().ok()) else {
        return RangeResult::Full;
    };
    let Some(spec) = value.trim().strip_prefix("bytes=") else {
        return RangeResult::Full;
    };
    let spec = spec.split(',').next().unwrap_or("").trim();
    let Some((start_s, end_s)) = spec.split_once('-') else {
        return RangeResult::Full;
    };
    let (start_s, end_s) = (start_s.trim(), end_s.trim());

    if total_len == 0 {
        return RangeResult::Unsatisfiable;
    }
    let last = total_len - 1;

    if start_s.is_empty() {
        // Suffix range: last N bytes.
        let Ok(n) = end_s.parse::<u64>() else { return RangeResult::Full };
        if n == 0 {
            return RangeResult::Unsatisfiable;
        }
        return RangeResult::Partial(total_len.saturating_sub(n), last);
    }

    let Ok(start) = start_s.parse::<u64>() else { return RangeResult::Full };
    if start > last {
        return RangeResult::Unsatisfiable;
    }
    let end = if end_s.is_empty() {
        last
    } else {
        match end_s.parse::<u64>() {
            Ok(e) if e >= start => e.min(last),
            Ok(_) => return RangeResult::Unsatisfiable,
            Err(_) => return RangeResult::Full,
        }
    };
    RangeResult::Partial(start, end)
}

pub async fn new(headers: HeaderMap, Query(query): Query<InputPayload>) -> Response {
    let settings = match Settings::get() {
        Ok(s) => s.clone(),
        Err(e) => return error(StatusCode::INTERNAL_SERVER_ERROR, e),
    };

    let output_dir = PathBuf::from(&settings.paths.app_cache_dir)
        .join("torrent_session_cache")
        .join("stream")
        .join(encode(&query.view_id).to_string())
        .join(query.season.to_string())
        .join(query.episode.to_string());

    let torrent_handle_builder = TorrentHandle {
        torrent_handle_mode: TorrentHandleMode::from_str(&query.torrent_handle_mode),
        torrent_source: query.torrent_source.clone(),
        file_id: query.file_id as u64,
        output_dir,
    };

    // Load (or reuse) the torrent, and wait for it to be initialized
    // instead of failing the request while it is still starting up.
    let torrent_handle = match torrent_handle_builder.load().await {
        Ok((h, _)) => h,
        Err(e) => return error(StatusCode::SERVICE_UNAVAILABLE, e),
    };

    if matches!(torrent_handle.stats().state, TorrentStatsState::Initializing) {
        match tokio::time::timeout(INIT_TIMEOUT, torrent_handle.wait_until_initialized()).await {
            Ok(Ok(())) => {}
            Ok(Err(e)) => return error(StatusCode::SERVICE_UNAVAILABLE, e),
            Err(_) => {
                return error(
                    StatusCode::SERVICE_UNAVAILABLE,
                    "Timed out waiting for torrent to initialize",
                )
            }
        }
    }

    if let TorrentStatsState::Error = torrent_handle.stats().state {
        return error(StatusCode::INTERNAL_SERVER_ERROR, "Torrent is in error state");
    }

    let mut stream = match torrent_handle.stream(query.file_id) {
        Ok(s) => s,
        Err(e) => return error(StatusCode::INTERNAL_SERVER_ERROR, e),
    };

    let total_len = stream.len();

    let mut out = HeaderMap::new();
    out.insert(header::ACCEPT_RANGES, HeaderValue::from_static("bytes"));
    out.insert(
        header::CONTENT_TYPE,
        HeaderValue::from_str(&query.mime_type)
            .unwrap_or_else(|_| HeaderValue::from_static("application/octet-stream")),
    );

    let (status, start, end) = match parse_range(&headers, total_len) {
        RangeResult::Full => (StatusCode::OK, 0, total_len.saturating_sub(1)),
        RangeResult::Partial(s, e) => (StatusCode::PARTIAL_CONTENT, s, e),
        RangeResult::Unsatisfiable => {
            out.insert(
                header::CONTENT_RANGE,
                HeaderValue::from_str(&format!("bytes */{}", total_len)).unwrap(),
            );
            return (StatusCode::RANGE_NOT_SATISFIABLE, out).into_response();
        }
    };

    let content_length = if total_len == 0 { 0 } else { end - start + 1 };

    println!(
        "[stream_video] {} START: {}, END: {}, TOTAL: {}",
        status.as_u16(),
        start,
        end,
        total_len
    );

    if start > 0 {
        if let Err(e) = stream.seek(SeekFrom::Start(start)).await {
            return error(StatusCode::INTERNAL_SERVER_ERROR, format!("seek failed: {e}"));
        }
    }

    out.insert(header::CONTENT_LENGTH, HeaderValue::from(content_length));
    if status == StatusCode::PARTIAL_CONTENT {
        out.insert(
            header::CONTENT_RANGE,
            HeaderValue::from_str(&format!("bytes {}-{}/{}", start, end, total_len)).unwrap(),
        );
    }

    let body = Body::from_stream(ReaderStream::with_capacity(
        stream.take(content_length),
        CHUNK_SIZE,
    ));

    (status, out, body).into_response()
}
