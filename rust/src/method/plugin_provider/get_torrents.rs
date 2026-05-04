use std::path::PathBuf;
use serde::{Deserialize, Serialize};

use tokio;

use recombox_plugin_provider::get_torrents::{self, InputPayload};
use recombox_plugin_provider::global_types::Source;

use crate::utils::settings::Settings;



#[derive(Debug, Deserialize, Serialize)]
pub struct TorrentInfo{
    pub title: String,
    pub torrent_url: String,
}


pub async fn get_torrents(
    plugin_path: String,
    source: String, 
    id: String,
    page: u64,

) -> Result<Vec<TorrentInfo>, String> {
    let source = Source::from_str(&source)
        .ok_or("Invalid Source")
        .map_err(|e| e.to_string())?;
    
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let real_plugin_path = PathBuf::from(&settings.paths.app_support_dir)
        .join("plugins")
        .join(&plugin_path);

    let data = tokio::task::spawn_blocking(move || {
        tokio::runtime::Handle::current().block_on(async {
            get_torrents::new(
                InputPayload {
                    plugin_path: PathBuf::from(real_plugin_path),
                    source: source,
                    id: id,
                    page,
                },
            ).await.unwrap()
        })
    })
    .await
    .map_err(|e| e.to_string())?;

    let result: Vec<TorrentInfo> = data.0.iter()
        .map(|info| TorrentInfo {
            title: info.title.to_owned(),
            torrent_url: info.torrent_url.to_owned(),
        })
        .collect();

    return Ok(result);
}