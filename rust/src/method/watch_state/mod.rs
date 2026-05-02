pub mod set_watch_state;
pub mod get_watch_state;

pub use redb::Database;
use redb::{TableDefinition};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::sync::{RwLock, Arc};
use once_cell::sync::Lazy;
use std::fs;

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Arc<Database>>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "watch_state.redb";
const WATCH_STATE_TABLE: TableDefinition<&[u8], &[u8]> = TableDefinition::new("watch_state");

const WATCH_STATE_ORDER_TABLE: TableDefinition<u64, &[u8]> = TableDefinition::new("watch_state_order");


#[derive(Serialize, Deserialize)]
pub struct WatchStateKey{
    pub source: String,
    pub id: String,
    pub season_index: u64,
    pub episode_index: u64,
}

#[derive(Serialize, Deserialize)]
pub struct WatchStateValue{
    pub position: Option<u64>,
}



pub fn get_db() -> Result<Arc<Database>, String> {
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let db_dir = PathBuf::from(&settings.paths.app_support_dir)
        .join("state");

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