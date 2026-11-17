pub mod stream_video;

use axum::{routing::get, Router};

pub fn routes() -> Router {
    Router::new().route("/stream_video", get(stream_video::new))
}
