use std::path::PathBuf;


use recombox_plugin_provider::manage_plugin::{install_plugin::{
    self, InputPayload
}};
use recombox_plugin_provider::global_types::Source;

use crate::utils::settings::Settings;

use super::PluginInfo;



pub async fn install_plugin(source: &str, plugin_info: &PluginInfo) -> Result<(), String> {
    let source = Source::from_str(source)
        .ok_or("Invalid Source")
        .map_err(|e| e.to_string())?;
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let plugin_dir = PathBuf::from(&settings.paths.app_support_dir)
        .join("plugins");


    install_plugin::new(
        InputPayload { 
            hashed_manifest_repo_id: plugin_info.hashed_manifest_repo_id.clone(),
            plugin_directory: plugin_dir, 
            plugin_source: source, 
            plugin_id: plugin_info.plugin_id.clone(), 
            plugin_repo_url: plugin_info.plugin_repo_url.clone()
        }
    ).await
    .map_err(|e| e.to_string())?;

    Ok(())
}