pub mod stream_video;

use actix_web::web;


pub fn routes(cfg: &mut web::ServiceConfig) {
    cfg
        .service(stream_video::new);
}