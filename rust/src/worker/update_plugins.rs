use anyhow;
use recombox_plugin_provider::manage_plugin::get_plugin_info;
use redb::{TableDefinition, ReadableDatabase, ReadableTable};
use std::num::NonZeroU32;
use std::sync::{RwLock, Arc};
use once_cell::sync::Lazy;
use std::fs;
use redb::Database;
use std::path::PathBuf;
use chrono::{Utc, DateTime};
use recombox_plugin_provider::{global_types::Source};
use tokio;
use semver;

use crate::method::plugin_provider::get_installed_plugins::{get_installed_plugins, InstalledPluginInfo};
use crate::method::plugin_provider::install_plugin::install_plugin;
use crate::method::plugin_provider::PluginInfo;
use crate::utils::settings::Settings;

const PER_PLUGIN_UPDATE_INTERVAL: i64 = 10; // In Minutes
static DATABASE: Lazy<RwLock<Option<Arc<Database>>>> = Lazy::new(|| RwLock::new(None));
const DATABASE_NAME: &str = "plugin_updater.redb";
const PLUGIN_LAST_UPDATE_TABLE: TableDefinition<&str, &str> = TableDefinition::new("plugin_last_update");


pub async fn start() -> anyhow::Result<()>{
    tokio::spawn( async move {
        loop {
            match tokio::spawn( async {
                let all_sources = Source::to_vec();
                for source in all_sources{
                    let installed_plugin_list = get_installed_plugins(source.as_str()).await.unwrap();

                    for (key, value) in &installed_plugin_list{
                        let is_should_check_update: bool = match should_check_update(value).await {
                            Ok(r) => r,
                            Err(e) => {
                                eprintln!("Failed to check if plugin {} should update: {}", key, e);
                                true
                            }
                        };
                        if is_should_check_update {
                            check_and_install_new_update(source.as_str(), key, value).await.unwrap();
                        }else{
                            println!("[PluginUpdater] Last check update was recent for plugin: {}. -> Skipping...", value.plugin_path);
                        }
                    }
                }
            }).await{
                Ok(_) => {}
                Err(e) => {
                    eprintln!("[PluginUpdater] Failed to update plugins: {}", e);
                }
            }

            tokio::time::sleep(tokio::time::Duration::from_mins(1)).await;
        }
    });

    return Ok(());
}


fn get_db() -> anyhow::Result<Arc<Database>> {
    let settings = Settings::get()?;

    fs::create_dir_all(&settings.paths.app_support_dir)?;

    let db_path = PathBuf::from(&settings.paths.app_support_dir)
        .join(DATABASE_NAME);
    let is_exist = fs::exists(&db_path)?;

    if is_exist {
        let read_gaurd = DATABASE.read()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;

        if let Some(db) = read_gaurd.clone() {
            return Ok(db);
        }
    }

    let mut write_gaurd = DATABASE.write()
        .map_err(|e| anyhow::Error::msg(e.to_string()))?;

    
    let db = Arc::new(
        Database::create(&db_path)
        .map_err(|e| anyhow::Error::msg(e.to_string()))?
    );
    
    *write_gaurd = Some(db.clone());
    return Ok(db.clone());
    
    
}

async fn should_check_update(installed_plugin_info: &InstalledPluginInfo) -> anyhow::Result<bool> {
    
    let db = get_db()?;

    let read_txn = db.begin_read()
        .map_err(|e| anyhow::Error::msg(e.to_string()))?;

    // If table doesn't exist, return empty map
    let last_update_table = match read_txn.open_table(PLUGIN_LAST_UPDATE_TABLE) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("[PluginUpdater] Failed to open table: {} -> should_update: true", e);
            return Ok(true);
        }
    };


    let raw_last_update_opt = last_update_table.get(installed_plugin_info.plugin_path.as_str())?;
    
    let last_update_opt: Option<DateTime<Utc>> = match raw_last_update_opt {
        Some(r) => {
            let last_update= match r.value().to_string().parse() {
                Ok(d) => {
                    Some(d)
                },
                Err(e) => {
                    eprint!("[PluginUpdater] Failed to parse last_update: {}", e);
                    None
                }
            };
            last_update
        },
        None => None
    };

    match last_update_opt {
        Some(last_update) => {
            if Utc::now() - last_update >= chrono::Duration::minutes(PER_PLUGIN_UPDATE_INTERVAL) {
                return Ok(true);
            }
        },
        None => {
            return Ok(true);
        }
    }

    return Ok(false);
}

async fn check_and_install_new_update(source: &str, plugin_id: &str, installed_plugin_info: &InstalledPluginInfo) -> anyhow::Result<()>{
    let remote_plugin_info = get_plugin_info::new(&installed_plugin_info.plugin_repo_url)
        .await?;
    let remote_version = semver::Version::parse(&remote_plugin_info.version)?;
    let installed_version = semver::Version::parse(&installed_plugin_info.plugin_version)?;
    println!("[PluginUpdater] PluginPath: {}", installed_plugin_info.plugin_path);
    println!("[PluginUpdater] Remote Version: {}, Installed Version: {}", remote_version, installed_version);
    if remote_version > installed_version {
        let plugin_info = PluginInfo { 
            hashed_manifest_repo_id: installed_plugin_info.hashed_manifest_repo_id.clone(), 
            manifest_repo_name: installed_plugin_info.manifest_repo_name.clone(), 
            plugin_id: plugin_id.to_string(), 
            plugin_name: installed_plugin_info.plugin_name.clone(), 
            plugin_repo_url: installed_plugin_info.plugin_repo_url.clone(), 
            plugin_icon_url: installed_plugin_info.plugin_icon_url.clone()
        };
        println!("[PluginUpdater] Installing new plugin version for: {}", installed_plugin_info.plugin_path);
        install_plugin(
            source,
            &plugin_info
        ).await.map_err(|e| anyhow::Error::msg(e.to_string()))?;
    }else{
        println!("[PluginUpdater] Already up-to-date for plugin: {}. -> Skipping...", installed_plugin_info.plugin_path);
    }

    save_last_update(&installed_plugin_info.plugin_path).await?;

    return Ok(());
}

async fn save_last_update(plugin_path: &str) -> anyhow::Result<()> {
    let db = get_db()?;
    let write_txn = db.begin_write()
        .map_err(|e| anyhow::Error::msg(e.to_string()))?;
    
    {
        let mut last_update_table = write_txn.open_table(PLUGIN_LAST_UPDATE_TABLE)?;

        let now = Utc::now().to_rfc3339();

        last_update_table.insert(plugin_path, now.as_str())?;
    }

    write_txn.commit()
        .map_err(|e| anyhow::Error::msg(e.to_string()))?;
    
    return Ok(());
}