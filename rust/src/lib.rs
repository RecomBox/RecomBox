pub mod utils;
pub mod method;
pub mod api;
pub mod frb_generated;

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test] 
    async fn test_get_torrent_info() {
        
        utils::torrent_session::TorrentSession::init().await.unwrap();
        method::generate_torrent_handle::generate_torrent_handle("D:\\Codes\\RecomBox\\rust\\test.torrent", 1).await.unwrap();


        let result = method::get_torrent_info::get_torrent_info(r"D:\Codes\RecomBox\rust\test.torrent")
            .await.unwrap();

        println!("{:?}", result);
        method::spawn_stream_server::spawn_stream_server().await.unwrap();
    }
}
