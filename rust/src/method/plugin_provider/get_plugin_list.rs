use std::collections::HashMap;
use std::path::PathBuf;

use recombox_plugin_provider::manage_plugin::{
    get_plugin_list::{self, InputPayload},
    PluginDatabaseManager
};

use recombox_plugin_provider::global_types::Source;
use serde::{Serialize, Deserialize};
use flutter_rust_bridge::frb;

use crate::utils::settings::Settings;

use super::PluginInfo;


// Return <plugin_id, InstalledPluginInfo>
pub async fn get_plugin_list(source: &str) -> Result<Vec<PluginInfo>, String> {
    let source = Source::from_str(source)
        .ok_or("Invalid Source")
        .map_err(|e| e.to_string())?;


    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let plugin_dir = PathBuf::from(&settings.paths.app_support_dir)
        .join("plugins");

    let plugin_db_manager = PluginDatabaseManager{
        plugin_directory: plugin_dir
    };

    let all_manifest_repo = plugin_db_manager.get_installed_manifest_repo().await
        .map_err(|e| e.to_string())?;

    let mut result: Vec<PluginInfo> = Vec::new();

    for (k, installed_manifest_info) in all_manifest_repo.0.iter().enumerate() {
        let plugin_info = get_plugin_list::new(InputPayload { 
            manifest_repo_url: installed_manifest_info.manifest_repo_url.clone(), 
            source: source.clone()
        }).await
        .map_err(|e| e.to_string())?;

        for (plugin_id, plugin_info) in plugin_info.0.iter() {
            result.push(PluginInfo{
                hashed_manifest_repo_id: installed_manifest_info.hashed_manifest_repo_id.clone(),
                manifest_repo_name: installed_manifest_info.manifest_repo_name.clone(),
                plugin_id: plugin_id.clone(),
                plugin_name: plugin_info.name.clone(),
                plugin_repo_url: plugin_info.repo_url.clone(),
                plugin_icon_url: plugin_info.icon_url.clone(),
            });
        }
    }



    return Ok(result);
}