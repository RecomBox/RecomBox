use super::{get_db, rusqlite, LastWatchTorrentInfo};

pub async fn get_last_watch_torrent(
    source: &str,
    id: &str,
    season_index: u64,
    episode_index: u64,
) -> anyhow::Result<Option<LastWatchTorrentInfo>, String> {
    let db = get_db().await?;

    let source_owned = source.to_string();
    let id_owned = id.to_string();
    let season = season_index as i64;
    let episode = episode_index as i64;

    let info = db
        .call(move |conn| -> Result<Option<LastWatchTorrentInfo>, rusqlite::Error> {
            let result = conn.query_row(
                "SELECT torrent_source, file_id, mime_type FROM last_watch_torrent
                 WHERE source = ?1 AND item_id = ?2 AND season_index = ?3 AND episode_index = ?4",
                rusqlite::params![source_owned, id_owned, season, episode],
                |row| {
                    Ok(LastWatchTorrentInfo {
                        torrent_source: row.get(0)?,
                        file_id: row.get::<_, i64>(1)? as u64,
                        mime_type: row.get(2)?,
                    })
                },
            );

            match result {
                Ok(info) => Ok(Some(info)),
                Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
                Err(e) => Err(e),
            }
        })
        .await
        .map_err(|e| e.to_string())?;

    return Ok(info);
}
