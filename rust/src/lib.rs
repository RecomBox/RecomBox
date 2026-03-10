pub mod utils;
pub mod api;
pub mod frb_generated;
use std::path::PathBuf;

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test] // or #[test] if not async
    async fn test_get_torrent_info() {
        let result = api::get_torrent_info::get_torrent_info(r"D:\Codes\RecomBox\recombox\rust\test4.torrent")
            .await.unwrap();

        println!("{:?}", result);
    }
}
