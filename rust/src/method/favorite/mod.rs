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

pub use tokio_rusqlite::Connection;
pub use tokio_rusqlite::rusqlite;
use serde::{Deserialize, Serialize};

use std::collections::HashMap;
use std::path::PathBuf;
use tokio::sync::RwLock;
use once_cell::sync::Lazy;
use std::fs;

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Connection>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "favorite_v2.sqlite3";

#[derive(Serialize, Deserialize)]
pub struct CategoryMap(pub HashMap<u64, String>);

#[derive(Serialize, Deserialize)]
pub struct CategoryOrderMap(pub HashMap<u64, u64>);

#[derive(Serialize, Deserialize)]
pub struct FavoriteItemInfo {
    pub source: String,
    pub id: String,
}

#[derive(Serialize, Deserialize)]
pub struct LastWatchTorrentInfo {
    pub torrent_source: String,
    pub file_id: u64,
    pub mime_type: String,
}

async fn get_db_path() -> Result<PathBuf, String> {
    let settings = Settings::get().map_err(|e| e.to_string())?;

    let db_dir = PathBuf::from(&settings.paths.app_support_dir).join("favorite");

    fs::create_dir_all(&db_dir).map_err(|e| e.to_string())?;

    Ok(db_dir.join(DATABASE_NAME))
}

pub async fn get_db() -> Result<Connection, String> {
    {
        let read_guard = DATABASE.read().await;
        if let Some(db) = read_guard.as_ref() {
            return Ok(db.clone());
        }
    }

    let mut write_guard = DATABASE.write().await;

    // Another task may have already initialized it while we were waiting for the write lock
    if let Some(db) = write_guard.as_ref() {
        return Ok(db.clone());
    }

    let db_path = get_db_path().await?;

    let conn = Connection::open(&db_path)
        .await
        .map_err(|e| e.to_string())?;

    conn.call(|conn| -> Result<(), rusqlite::Error> {
        conn.execute_batch(
            "
            PRAGMA foreign_keys = ON;

            CREATE TABLE IF NOT EXISTS category (
                id             INTEGER PRIMARY KEY,
                name           TEXT NOT NULL,
                order_position INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS category_item (
                category_id INTEGER NOT NULL,
                source      TEXT NOT NULL,
                item_id     TEXT NOT NULL,
                PRIMARY KEY (category_id, source, item_id),
                FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE CASCADE
            );

            CREATE INDEX IF NOT EXISTS idx_category_item_source_item
                ON category_item (source, item_id);

            CREATE TABLE IF NOT EXISTS last_watch_torrent (
                source         TEXT NOT NULL,
                item_id        TEXT NOT NULL,
                season_index   INTEGER NOT NULL,
                episode_index  INTEGER NOT NULL,
                torrent_source TEXT NOT NULL,
                file_id        INTEGER NOT NULL,
                mime_type      TEXT NOT NULL,
                PRIMARY KEY (source, item_id, season_index, episode_index)
            );
            ",
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    *write_guard = Some(conn.clone());

    Ok(conn)
}

pub async fn get_favorite_db_path() -> Result<String, String> {
    let db_path = get_db_path().await?;
    Ok(db_path.to_str().unwrap_or("").to_string())
}
