use std::collections::HashMap;
use std::path::PathBuf;
use serde::{Deserialize, Serialize};
use flutter_rust_bridge::frb;


use recombox_plugin_provider::manage_plugin::PluginDatabaseManager;
use recombox_plugin_provider::global_types::Source;

use crate::utils::settings::Settings;


#[frb(json_serializable)]
#[derive(Debug, Deserialize, Serialize)]
pub struct InstalledPluginInfo{
    pub plugin_name: String,
    pub plugin_repo_url: String,
    pub plugin_icon_url: String,
    pub plugin_path: String,
    pub plugin_version: String
}

// Return <plugin_id, InstalledPluginInfo>
pub async fn get_installed_plugins(source: &str) -> Result<HashMap<String, InstalledPluginInfo>, String> {
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

    let installed_plugins = plugin_db_manager.get_installed_plugins(source).await
        .map_err(|e| e.to_string())?;


    let result: HashMap<String, InstalledPluginInfo> = installed_plugins.0.iter()
        .map(|(k, v)| {
            (
                k.clone(),
                InstalledPluginInfo {
                    plugin_name: v.plugin_name.clone(),
                    plugin_repo_url: v.plugin_repo_url.clone(),
                    plugin_icon_url: v.plugin_icon_url.clone(),
                    plugin_path: v.plugin_path.clone(),
                    plugin_version: v.plugin_version.clone(),
                },
                
            )
        })
        .collect();


    Ok(result)
}