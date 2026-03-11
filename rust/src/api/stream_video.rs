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

use crate::utils::torrent_handle::TORRENT_HANDLE;

#[get("/stream_video")]
pub async fn new(req: HttpRequest) -> HttpResponse {
    let headers = req.headers();

    let torrent_file = PathBuf::from(r"D:\\Codes\\RecomBox\\rust\\test.torrent");
    let file_id = 1;
    
    let mut stream = TORRENT_HANDLE.get(&torrent_file).unwrap().clone()
        .get(&file_id).unwrap().clone()
        .stream(file_id).unwrap();
    
    
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

    stream.seek(SeekFrom::Start(start)).await.unwrap();
    let reader_stream = ReaderStream::new(stream);
    let body = actix_web::body::BodyStream::new(reader_stream);

    println!("Proccessed");

    if headers.get("range").is_some() {
        // Range request → 206
        HttpResponse::PartialContent()
            .append_header(("Accept-Ranges", "bytes"))
            .append_header(("Content-Type", "video/x-matroska"))
            .append_header(("Content-Length", content_length.to_string()))
            .append_header((
                "Content-Range",
                format!("bytes {}-{}/{}", start, actual_end, total_len),
            ))
            .body(body)
    } else {
        // No range → 200
        HttpResponse::Ok()
            .append_header(("Content-Type", "video/x-matroska"))
            .append_header(("Content-Length", total_len.to_string()))
            .body(body)
    }
    
}


