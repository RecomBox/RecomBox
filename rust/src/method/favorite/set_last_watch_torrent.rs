use super::{get_db, rusqlite, LastWatchTorrentInfo};

pub async fn set_last_watch_torrent(
    source: &str,
    id: &str,
    season_index: u64,
    episode_index: u64,
    last_watch_torrent_info: LastWatchTorrentInfo,
) -> Result<(), String> {
    let db = get_db().await?;

    let source_owned = source.to_string();
    let id_owned = id.to_string();
    let season = season_index as i64;
    let episode = episode_index as i64;
    let file_id = last_watch_torrent_info.file_id as i64;
    let torrent_source = last_watch_torrent_info.torrent_source;
    let mime_type = last_watch_torrent_info.mime_type;

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        conn.execute(
            "INSERT INTO last_watch_torrent
                (source, item_id, season_index, episode_index, torrent_source, file_id, mime_type)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
             ON CONFLICT (source, item_id, season_index, episode_index)
             DO UPDATE SET
                torrent_source = excluded.torrent_source,
                file_id        = excluded.file_id,
                mime_type      = excluded.mime_type",
            rusqlite::params![
                source_owned,
                id_owned,
                season,
                episode,
                torrent_source,
                file_id,
                mime_type,
            ],
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    return Ok(());
}
