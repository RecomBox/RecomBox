use actix_web::{
    get,
    web,
    App,
    HttpRequest,
    HttpResponse,
    HttpServer,
};
use std::io::SeekFrom;
use tokio::io::AsyncSeekExt;
use tokio_util::io::ReaderStream;
use std::path::PathBuf;
use tokio;
use serde::{Deserialize, Serialize};
use urlencoding::{encode, decode};
use once_cell::sync::Lazy;
use tokio::runtime::Runtime;
use num_cpus;

use crate::utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode};
use crate::utils::settings::Settings;

#[derive(Deserialize, Serialize)]
struct InputPayload {
    torrent_handle_mode: String,
    torrent_source: String,
    mime_type: String,
    file_id: usize,
    view_id: String,
    season: u64,
    episode: u64
}

static RUNTIME: Lazy<Runtime> = Lazy::new(|| {
    tokio::runtime::Builder::new_multi_thread()
        .worker_threads(num_cpus::get())
        .enable_all()
        .build()
        .expect("Failed to build multi-threaded runtime")
});

#[get("/stream_video")]
pub async fn new(req: HttpRequest, query: web::Query<InputPayload>) -> Result<HttpResponse, actix_web::Error>{
    let headers = req.headers();

    let settings = Settings::get()
        .map_err(|e| actix_web::error::ErrorInternalServerError(e.to_string()))?
        .clone();

    let torrent_handle_mode = TorrentHandleMode::from_str(&query.torrent_handle_mode);

    let cache_dir = &settings.paths.app_cache_dir;

    let output_dir = PathBuf::from(cache_dir)
        .join("torrent_session_cache")
        .join("stream")
        .join(encode(&query.view_id.to_string()).to_string())
        .join(query.season.to_string())
        .join(query.episode.to_string());

    let torrent_handle_builder = TorrentHandle{
        torrent_handle_mode: torrent_handle_mode,
        torrent_source:  query.torrent_source.clone(),
        file_id:  query.file_id as u64,
        output_dir: output_dir
    };

    let (torrent_handle,  _) = RUNTIME.spawn(async move {
        torrent_handle_builder.load().await.unwrap()
    })
        .await
        .map_err(|e| actix_web::error::ErrorInternalServerError(e.to_string()))?;

    
    let mut stream = torrent_handle
        .stream(query.file_id)
        .map_err(|e| actix_web::error::ErrorInternalServerError(e.to_string()))?;

    // -> Identify byte range
    
    let total_len = stream.len();

    let mut start: u64 = 0;
    let mut end: Option<u64> = None;

    if let Some(range_header) = headers.get("range") {
        if let Ok(range_str) = range_header.to_str() {
            if let Some(range) = range_str.strip_prefix("bytes=") {
                let parts: Vec<&str> = range.split('-').collect();
                if let Ok(s) = parts[0].parse::<u64>() {
                    start = s;
                }
                if parts.len() > 1 && !parts[1].is_empty() {
                    if let Ok(e) = parts[1].parse::<u64>() {
                        end = Some(e);
                    }
                }
            }
        }
    }

    let actual_end = end.unwrap_or(total_len - 1);
    let content_length = actual_end - start + 1;

    println!("START: {}, END: {}, TOTAL: {}", start, actual_end, total_len);

    // <-

    stream.seek(SeekFrom::Start(start)).await.unwrap();
    let reader_stream = ReaderStream::new(stream);
    let body = actix_web::body::BodyStream::new(reader_stream);


    if headers.get("range").is_some() {
        // Range request → 206
        Ok(
            HttpResponse::PartialContent()
                .append_header(("Accept-Ranges", "bytes"))
                .append_header(("Content-Type", query.mime_type.clone()))
                .append_header(("Content-Length", content_length.to_string()))
                .append_header((
                    "Content-Range",
                    format!("bytes {}-{}/{}", start, actual_end, total_len),
                ))
                .body(body)
        )
    } else {
        // No range → 200
        Ok(
            HttpResponse::Ok()
                .append_header(("Content-Type", query.mime_type.clone()))
                .append_header(("Content-Length", total_len.to_string()))
                .body(body)
        )
    }
    
}


