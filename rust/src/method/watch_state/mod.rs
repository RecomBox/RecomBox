pub mod set_watch_state;
pub mod get_watch_state;

pub use tokio_rusqlite::Connection;
pub use tokio_rusqlite::rusqlite;
use serde::{Deserialize, Serialize};

use std::path::PathBuf;
use tokio::sync::RwLock;
use once_cell::sync::Lazy;
use std::fs;

use crate::utils::settings::Settings;

static DATABASE: Lazy<RwLock<Option<Connection>>> = Lazy::new(|| RwLock::new(None));

const DATABASE_NAME: &str = "watch_state_v2.sqlite3";

#[derive(Serialize, Deserialize)]
pub struct WatchStateKey {
    pub source: String,
    pub id: String,
    pub season_index: u64,
    pub episode_index: u64,
}

#[derive(Serialize, Deserialize)]
pub struct WatchStateValue {
    pub position: Option<u64>,
}

async fn get_db_path() -> Result<PathBuf, String> {
    let settings = Settings::get().map_err(|e| e.to_string())?;

    let db_dir = PathBuf::from(&settings.paths.app_support_dir).join("state");

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
            CREATE TABLE IF NOT EXISTS watch_state (
                source        TEXT NOT NULL,
                item_id       TEXT NOT NULL,
                season_index  INTEGER NOT NULL,
                episode_index INTEGER NOT NULL,
                position      INTEGER,
                updated_at    INTEGER NOT NULL,
                PRIMARY KEY (source, item_id, season_index, episode_index)
            );

            CREATE INDEX IF NOT EXISTS idx_watch_state_updated_at
                ON watch_state (updated_at);
            ",
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    *write_guard = Some(conn.clone());

    Ok(conn)
}

pub async fn get_watch_state_db_path() -> Result<String, String> {
    let db_path = get_db_path().await?;
    Ok(db_path.to_str().unwrap_or("").to_string())
}
