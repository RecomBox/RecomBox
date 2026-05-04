use std::path::PathBuf;
use serde::{Deserialize, Serialize};

use tokio;

use recombox_plugin_provider::get_sources::{self, InputPayload};
use recombox_plugin_provider::global_types::Source;

use crate::utils::settings::Settings;



#[derive(Debug, Deserialize, Serialize)]
pub struct SourceInfo{
    pub id: String,
    pub title: String
}


pub async fn get_sources(
    plugin_path: String,
    source: String, 
    id: String,
    title: String,
    title_secondary: String,
    season: u64,
    episode: u64,
    search: String,
    page: u64,

) -> Result<Vec<SourceInfo>, String> {
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
            get_sources::new(
                InputPayload {
                    plugin_path: PathBuf::from(real_plugin_path),
                    source: source,
                    id: id,
                    title: title,
                    title_secondary: title_secondary,
                    season: Some(season),
                    episode: Some(episode),
                    search: Some(search),
                    page,
                },
            ).await.unwrap()
        })
    })
    .await
    .map_err(|e| e.to_string())?;

    let result: Vec<SourceInfo> = data.0.iter()
        .map(|info| SourceInfo {
            id: info.id.to_owned(),
            title: info.title.to_owned(),
        })
        .collect();

    return Ok(result);
}