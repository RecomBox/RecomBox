pub mod add_category;
pub mod set_category;
pub mod delete_category;
pub mod unset_category;
pub mod get_all_category;
pub mod get_all_category_by_item_id;
pub mod get_all_item_by_category_id;
pub mod get_category_order;
pub mod swap_category_order;
pub mod rename_category;
pub mod is_in_category;
pub mod get_last_watch_torrent;
pub mod set_last_watch_torrent;

pub use redb::Database;
use redb::{TableDefinition, MultimapTableDefinition};
use serde::{Deserialize, Serialize};

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{RwLock, Arc};
use once_cell::sync::Lazy;
use std::fs;

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Arc<Database>>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "favorite.redb";
const LAST_WATCH_TORRENT_TABLE: TableDefinition<&[u8], &[u8]> = TableDefinition::new("last_watch_torrent");
const CATEGORY_TABLE: TableDefinition<u64, &str> = TableDefinition::new("category");
const CATEGORY_ORDER_TABLE:TableDefinition<u64, u64> = TableDefinition::new("category_order");
const CATEGORY_AND_ITEM_TABLE: MultimapTableDefinition<u64, &[u8]> = MultimapTableDefinition::new("category_and_item");
const ITEM_AND_CATEGORY_TABLE: MultimapTableDefinition<&[u8], u64> = MultimapTableDefinition::new("item_and_category");



#[derive(Serialize, Deserialize)]
pub struct CategoryMap(pub HashMap<u64, String>);


#[derive(Serialize, Deserialize)]
pub struct CategoryOrderMap(pub HashMap<u64, u64>);

#[derive(Serialize, Deserialize)]
pub struct FavoriteItemInfo{
    pub source: String,
    pub id: String,
}


#[derive(Serialize, Deserialize)]
pub struct LastWatchTorrentInfo{
    pub torrent_source: String,
    pub file_id: u64,
    pub mime_type: String,
}




pub fn get_db() -> Result<Arc<Database>, String> {
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let db_dir = PathBuf::from(&settings.paths.app_support_dir)
        .join("favorite");

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