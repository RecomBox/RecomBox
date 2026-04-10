
use std::path::PathBuf;


use recombox_plugin_provider::manage_plugin::PluginDatabaseManager;
use recombox_plugin_provider::global_types::Source;

use crate::utils::settings::Settings;

use super::PluginInfo;



pub async fn remove_plugins(source: &str, plugin_info: &PluginInfo) -> Result<(), String> {
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

    plugin_db_manager.remove_plugin(
        &plugin_info.hashed_manifest_repo_id, 
        source,
        plugin_info.plugin_id.as_str()
    ).await
        .map_err(|e| e.to_string())?;   

    Ok(())
}