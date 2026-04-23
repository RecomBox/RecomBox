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


pub use redb::Database;
use redb::{TableDefinition, MultimapTableDefinition};
use serde::{Deserialize, Serialize};
use flutter_rust_bridge::frb;
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{RwLock, Arc};
use once_cell::sync::Lazy;
use std::fs;

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Arc<Database>>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "favorite.redb";
const CATEGORY_TABLE: TableDefinition<u64, &str> = TableDefinition::new("category");
const CATEGORY_ORDER_TABLE:TableDefinition<u64, u64> = TableDefinition::new("category_order");
const CATEGORY_AND_ITEM_TABLE: MultimapTableDefinition<u64, &[u8]> = MultimapTableDefinition::new("category_and_item");
const ITEM_AND_CATEGORY_TABLE: MultimapTableDefinition<&[u8], u64> = MultimapTableDefinition::new("item_and_category");


#[frb(json_serializable)]
#[derive(Serialize, Deserialize)]
pub struct CategoryMap(pub HashMap<u64, String>);

#[frb(json_serializable)]
#[derive(Serialize, Deserialize)]
pub struct CategoryOrderMap(pub HashMap<u64, u64>);


#[frb(json_serializable)]
#[derive(Serialize, Deserialize)]
pub struct ItemInfo{
    pub source: String,
    pub id: String,
}



pub fn get_db() -> Result<Arc<Database>, String> {
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    fs::create_dir_all(&settings.paths.app_support_dir)
        .map_err(|e| e.to_string())?;

    let db_path = PathBuf::from(&settings.paths.app_support_dir)
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