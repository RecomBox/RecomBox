use std::time::{SystemTime, UNIX_EPOCH};

use super::{get_db, rusqlite, RecentWatchInfo};

const MAX_RECENT_WATCH: i64 = 20;

pub async fn get_all_recent_watch() -> Result<Vec<RecentWatchInfo>, String> {
    let db = get_db().await?;

    let items = db
        .call(|conn| -> Result<Vec<RecentWatchInfo>, rusqlite::Error> {
            let mut stmt = conn.prepare(
                "SELECT source, item_id, season_index, episode_index FROM recent_watch
                 ORDER BY watched_at DESC
                 LIMIT ?1",
            )?;

            let rows = stmt.query_map(rusqlite::params![MAX_RECENT_WATCH], |row| {
                Ok(RecentWatchInfo {
                    source: row.get(0)?,
                    id: row.get(1)?,
                    season_index: row.get::<_, i64>(2)? as u64,
                    episode_index: row.get::<_, i64>(3)? as u64,
                })
            })?;

            let mut items = Vec::new();
            for row in rows {
                items.push(row?);
            }

            Ok(items)
        })
        .await
        .map_err(|e| e.to_string())?;

    Ok(items)
}

pub async fn set_recent_watch(
    source: &str,
    id: &str,
    season_index: u64,
    episode_index: u64,
) -> Result<(), String> {
    let db = get_db().await?;

    let source_owned = source.to_string();
    let id_owned = id.to_string();
    let season = season_index as i64;
    let episode = episode_index as i64;
    let watched_at = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| e.to_string())?
        .as_millis() as i64;

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        let tx = conn.transaction()?;

        // Insert the show, or if it already exists update its episode and
        // move it to the front by refreshing watched_at.
        tx.execute(
            "INSERT INTO recent_watch (source, item_id, season_index, episode_index, watched_at)
             VALUES (?1, ?2, ?3, ?4, ?5)
             ON CONFLICT (source, item_id)
             DO UPDATE SET
                season_index  = excluded.season_index,
                episode_index = excluded.episode_index,
                watched_at    = excluded.watched_at",
            rusqlite::params![source_owned, id_owned, season, episode, watched_at],
        )?;

        // Keep only the most recent MAX_RECENT_WATCH shows.
        tx.execute(
            "DELETE FROM recent_watch
             WHERE rowid NOT IN (
                SELECT rowid FROM recent_watch ORDER BY watched_at DESC LIMIT ?1
             )",
            rusqlite::params![MAX_RECENT_WATCH],
        )?;

        tx.commit()?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    return Ok(());
}
