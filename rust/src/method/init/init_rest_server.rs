use axum::{routing::get, Router};
use once_cell::sync::Lazy;
use tokio::runtime::Runtime;

use crate::api::routes;
use crate::utils::settings::Settings;

/// Dedicated runtime for the stream server.
///
/// Must NOT share flutter_rust_bridge's runtime: every torrent added by a stream request
/// (`TorrentHandle::load` -> `add_torrent`) spawns its peer/disk/hashing tasks on the
/// runtime it is called from. On the shared runtime they compete with every Dart -> Rust
/// call, and streaming stalled on Windows. The old actix version had this isolation
/// (actix threads + its own `RUNTIME`) and worked everywhere.
static STREAM_RUNTIME: Lazy<Runtime> = Lazy::new(|| {
    tokio::runtime::Builder::new_multi_thread()
        .thread_name("stream-server")
        .enable_all()
        .build()
        .expect("Failed to build stream server runtime")
});

pub async fn init_rest_server() -> Result<(), String> {
    let settings = Settings::get().map_err(|e| e.to_string())?;

    let addr = format!("127.0.0.1:{}", settings.port);

    let app = Router::new()
        .route("/ping", get(|| async { "pong" }))
        .merge(routes());

    // Bind inside the dedicated runtime so the listener's I/O is driven there,
    // and report bind errors back to the caller.
    let (bind_tx, bind_rx) = tokio::sync::oneshot::channel::<Result<(), String>>();

    STREAM_RUNTIME.spawn(async move {
        let listener = match tokio::net::TcpListener::bind(&addr).await {
            Ok(l) => l,
            Err(e) => {
                let _ = bind_tx.send(Err(e.to_string()));
                return;
            }
        };
        println!("Server listening on: http://{}/", addr);
        let _ = bind_tx.send(Ok(()));

        if let Err(e) = axum::serve(listener, app).await {
            eprintln!("REST server error: {}", e);
        }
    });

    bind_rx
        .await
        .map_err(|_| "Stream server task exited before binding".to_string())?
}
