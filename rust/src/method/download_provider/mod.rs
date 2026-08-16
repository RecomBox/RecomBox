pub mod set_download;
pub mod get_download;
pub mod remove_download;

pub mod get_all_download;
pub mod get_download_status;
pub mod set_download_status;

pub use tokio_rusqlite::Connection;
pub use tokio_rusqlite::rusqlite;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tokio::sync::RwLock;
use once_cell::sync::Lazy;
use std::fs;
use std::cmp::{Eq, PartialEq};
use flutter_rust_bridge::frb;

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Connection>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "download_v2.sqlite3";

#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct DownloadItemKey {
    pub source: String,
    pub id: String,
    pub season_index: u64,
    pub episode_index: u64,
}

#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct DownloadItemValue {
    pub torrent_source: String,
    pub file_id: u64,
    pub file_path: String,
    pub mime_type: String,
}

#[frb(json_serializable)]
#[derive(Debug, Serialize, Deserialize, Clone, Eq, PartialEq, Copy)]
pub struct DownloadStatus {
    pub progress_size: u64,
    pub total_size: u64,
    pub paused: bool,
    pub done: bool,
}

async fn get_db_path() -> Result<PathBuf, String> {
    let settings = Settings::get().map_err(|e| e.to_string())?;

    let db_dir = PathBuf::from(&settings.paths.app_support_dir).join("download");

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
            PRAGMA journal_mode = WAL;
            PRAGMA busy_timeout = 5000;
            PRAGMA synchronous = NORMAL;

            CREATE TABLE IF NOT EXISTS download (
                source         TEXT NOT NULL,
                item_id        TEXT NOT NULL,
                season_index   INTEGER NOT NULL,
                episode_index  INTEGER NOT NULL,
                torrent_source TEXT NOT NULL,
                file_id        INTEGER NOT NULL,
                file_path      TEXT NOT NULL,
                mime_type      TEXT NOT NULL,
                PRIMARY KEY (source, item_id, season_index, episode_index)
            );

            CREATE TABLE IF NOT EXISTS download_status (
                source        TEXT NOT NULL,
                item_id       TEXT NOT NULL,
                season_index  INTEGER NOT NULL,
                episode_index INTEGER NOT NULL,
                progress_size INTEGER NOT NULL,
                total_size    INTEGER NOT NULL,
                paused        INTEGER NOT NULL,
                done          INTEGER NOT NULL,
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