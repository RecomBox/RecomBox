use axum::{routing::get, Router};
use tokio;

use crate::api::routes;
use crate::utils::settings::Settings;

pub async fn init_rest_server() -> Result<(), String> {
    let settings = Settings::get().map_err(|e| e.to_string())?;

    let free_port = settings.port;
    let addr = format!("127.0.0.1:{}", free_port);

    let listener = tokio::net::TcpListener::bind(&addr)
        .await
        .map_err(|e| e.to_string())?;

    println!("Server listening on: http://{}/", addr);

    let app = Router::new()
        .route("/ping", get(|| async { "pong" }))
        .merge(routes());

    tokio::spawn(async move {
        if let Err(e) = axum::serve(listener, app).await {
            eprintln!("REST server error: {}", e);
        }
    });

    Ok(())
}
