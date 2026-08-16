use anyhow::{Context, Result};

use super::{get_db, rusqlite, WatchStateKey, WatchStateValue};

pub async fn get_watch_state(watch_state_key: WatchStateKey) -> Result<Option<WatchStateValue>> {
    let db = get_db().await.map_err(|e| anyhow::anyhow!(e))?;

    let source = watch_state_key.source;
    let id = watch_state_key.id;
    let season_index = watch_state_key.season_index as i64;
    let episode_index = watch_state_key.episode_index as i64;

    let value = db
        .call(move |conn| -> Result<Option<Option<u64>>, rusqlite::Error> {
            let result = conn.query_row(
                "SELECT position FROM watch_state
                 WHERE source = ?1 AND item_id = ?2 AND season_index = ?3 AND episode_index = ?4",
                rusqlite::params![source, id, season_index, episode_index],
                |row| {
                    let position: Option<i64> = row.get(0)?;
                    Ok(position.map(|p| p as u64))
                },
            );

            match result {
                Ok(position) => Ok(Some(position)),
                Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
                Err(e) => Err(e),
            }
        })
        .await
        .context("Database read error")?;

    Ok(value.map(|position| WatchStateValue { position }))
}
