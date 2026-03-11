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


use crate::api::{stream_video};

pub async fn spawn_stream_server() -> Result<(), String> {
    tokio::spawn(async move {
        let addr = "127.0.0.1:8080";
        println!("Server listening on: http://{}/", addr);

        HttpServer::new(|| {
            App::new()
                .service(stream_video::new)
        })
            .bind(addr).unwrap()
            .run()
            .await.unwrap();

    }).await
    .map_err(|e| e.to_string())?;

    return Ok(());
}