use super::{get_db, rusqlite, DownloadItemKey, DownloadItemValue};

pub async fn set_download(download_item_key: &DownloadItemKey, download_item_value: &DownloadItemValue) -> Result<(), String> {
    let db = get_db().await?;

    let source = download_item_key.source.clone();
    let id = download_item_key.id.clone();
    let season_index = download_item_key.season_index as i64;
    let episode_index = download_item_key.episode_index as i64;
    let torrent_source = download_item_value.torrent_source.clone();
    let file_id = download_item_value.file_id as i64;
    let file_path = download_item_value.file_path.clone();
    let mime_type = download_item_value.mime_type.clone();

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        conn.execute(
            "INSERT INTO download
                (source, item_id, season_index, episode_index, torrent_source, file_id, file_path, mime_type)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
             ON CONFLICT (source, item_id, season_index, episode_index)
             DO UPDATE SET
                torrent_source = excluded.torrent_source,
                file_id        = excluded.file_id,
                file_path      = excluded.file_path,
                mime_type      = excluded.mime_type",
            rusqlite::params![source, id, season_index, episode_index, torrent_source, file_id, file_path, mime_type],
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    return Ok(());
}
