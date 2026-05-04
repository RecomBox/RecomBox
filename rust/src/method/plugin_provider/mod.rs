pub mod get_installed_plugins;
pub mod get_plugin_list;
pub mod install_plugin;
pub mod remove_plugin;
pub mod get_sources;
pub mod get_torrents;

use serde::{Deserialize, Serialize};




#[derive(Debug, Deserialize, Serialize)]
pub struct PluginInfo{
    pub hashed_manifest_repo_id: String,
    pub manifest_repo_name: String,
    pub plugin_id: String,
    pub plugin_name: String,
    pub plugin_repo_url: String,
    pub plugin_icon_url: String,

}