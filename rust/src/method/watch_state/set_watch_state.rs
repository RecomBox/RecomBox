use chrono::Utc;

use super::{get_db, rusqlite, WatchStateKey, WatchStateValue};

pub async fn set_watch_state(
    watch_state_key: WatchStateKey,
    watch_state_value: WatchStateValue,
) -> Result<(), String> {
    let db = get_db().await?;
    let max_history: i64 = 500;

    let source = watch_state_key.source;
    let id = watch_state_key.id;
    let season_index = watch_state_key.season_index as i64;
    let episode_index = watch_state_key.episode_index as i64;
    let position: Option<i64> = watch_state_value.position.map(|p| p as i64);
    let now = Utc::now().timestamp();

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        let tx = conn.transaction()?;

        // -> Prune the oldest entries once history reaches max_history, mirroring the
        //    previous redb order-table eviction.
        let count: i64 = tx.query_row("SELECT COUNT(*) FROM watch_state", [], |row| row.get(0))?;

        if count >= max_history {
            let to_prune = count - max_history + 1;
            tx.execute(
                "DELETE FROM watch_state WHERE rowid IN (
                    SELECT rowid FROM watch_state ORDER BY updated_at ASC LIMIT ?1
                )",
                rusqlite::params![to_prune],
            )?;
        }
        // <-

        tx.execute(
            "INSERT INTO watch_state (source, item_id, season_index, episode_index, position, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6)
             ON CONFLICT (source, item_id, season_index, episode_index)
             DO UPDATE SET position = excluded.position, updated_at = excluded.updated_at",
            rusqlite::params![source, id, season_index, episode_index, position, now],
        )?;

        tx.commit()?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    Ok(())
}
