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
use num_cpus;


use crate::{ utils::settings::Settings};
use crate::api::routes;

pub async fn init_rest_server() -> Result<(), String> {

    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let free_port = settings.port;
    let addr = format!("127.0.0.1:{}", free_port);

    println!("Server listening on: http://{}/", addr);

    tokio::spawn(async move {
        
        HttpServer::new(|| {
            App::new()
                .route("/ping", actix_web::web::get().to(|| async { HttpResponse::Ok().body("pong") }))
                .configure(routes)
                
        })
            .bind(addr)
            .unwrap()
            .run()
            .await.unwrap();
    });

    return Ok(());
}