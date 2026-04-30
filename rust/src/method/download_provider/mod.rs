pub mod set_download;
pub mod get_download;
pub mod remove_download;

pub mod get_all_download;
pub mod get_download_status;
pub mod set_download_status;

pub use redb::Database;
use redb::{TableDefinition};
use serde::{Deserialize, Serialize};
use flutter_rust_bridge::frb;
use std::path::PathBuf;
use std::sync::{RwLock, Arc};
use once_cell::sync::Lazy;
use std::fs;
use std::cmp::{Eq, PartialEq};

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Arc<Database>>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "download.redb";
const DOWNLOAD_TABLE: TableDefinition<&[u8], &[u8]> = TableDefinition::new("download");
const DOWNLOAD_STATUS_TABLE: TableDefinition<&[u8], &[u8]> = TableDefinition::new("download_status");


#[frb(json_serializable)]
#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct DownloadItemKey{
    pub source: String,
    pub id: String,
    pub season_index: u64,
    pub episode_index: u64,
}

#[frb(json_serializable)]
#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct DownloadItemValue{
    pub torrent_source: String,
    pub file_id: u64,
    pub file_path: String,
    pub mime_type: String,
}


#[frb(json_serializable)]
#[derive(Debug, Serialize, Deserialize)]
pub struct DownloadStatus{
    pub progress_size: u64,
    pub total_size: u64,
    pub paused: bool,
    pub done: bool,
}


pub fn get_db() -> Result<Arc<Database>, String> {
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let db_dir = PathBuf::from(&settings.paths.app_support_dir)
        .join("download");

    fs::create_dir_all(&db_dir)
        .map_err(|e| e.to_string())?;

    let db_path = PathBuf::from(&db_dir)
        .join(DATABASE_NAME);
    
    let is_exist = fs::exists(&db_path)
        .map_err(|e| e.to_string())?;

    if is_exist {
        let read_gaurd = DATABASE.read()
            .map_err(|e| e.to_string())?;

        if let Some(db) = read_gaurd.clone() {
            return Ok(db);
        }
    }

    let mut write_gaurd = DATABASE.write()
        .map_err(|e| e.to_string())?;
    
    let db = Arc::new(Database::create(&db_path)
        .map_err(|e| e.to_string())?);
    
    *write_gaurd = Some(db.clone());
    return Ok(db.clone());
    
    
}