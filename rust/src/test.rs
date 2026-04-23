
#[cfg(test)]
mod tests {
    use super::*;
    
    // #[tokio::test] 
    // async fn test_get_torrent_info() {
    //     use crate::{api, utils, method};
        
    //     utils::torrent_session::TorrentSession::init().await.unwrap();

    //     let url = "https://yts.bz/torrent/download/CE202BCAE070A04BFBFB2C96355B058612B05493";

    //     method::generate_torrent_handle::generate_torrent_handle(url.to_string(), 0).await.unwrap();


    //     let result = method::get_torrent_metadata::get_torrent_info(url.to_string())
    //         .await.unwrap();

    //     println!("{:?}", result);
    //     method::init_stream_server::spawn_stream_server().await.unwrap();
    // }


    // #[tokio::test] 
    async fn test_get_installed_plugins() {
        use crate::{method::plugin_provider::get_installed_plugins::get_installed_plugins};
        use crate::utils::settings::Settings;

        Settings::temp_init().unwrap();

        let result = get_installed_plugins("anime").await.unwrap();
        println!("{:?}", result);
    }

    #[tokio::test] 
    async fn test_get_plugin_list() {
        use crate::{method::plugin_provider::get_plugin_list::get_plugin_list};
        use crate::utils::settings::Settings;

        Settings::temp_init().unwrap();

        let result = get_plugin_list("anime").await.unwrap();
        println!("{:?}", result);
    }
    
}
