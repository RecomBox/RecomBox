use super::{get_db, rusqlite, DownloadItemKey, DownloadItemValue};

pub async fn get_download(
    download_item_key: &DownloadItemKey,
) -> Result<Option<DownloadItemValue>, String> {
    let db = get_db().await?;

    let source = download_item_key.source.clone();
    let id = download_item_key.id.clone();
    let season_index = download_item_key.season_index as i64;
    let episode_index = download_item_key.episode_index as i64;

    let value = db
        .call(move |conn| -> Result<Option<DownloadItemValue>, rusqlite::Error> {
            let result = conn.query_row(
                "SELECT torrent_source, file_id, file_path, mime_type FROM download
                 WHERE source = ?1 AND item_id = ?2 AND season_index = ?3 AND episode_index = ?4",
                rusqlite::params![source, id, season_index, episode_index],
                |row| {
                    Ok(DownloadItemValue {
                        torrent_source: row.get(0)?,
                        file_id: row.get::<_, i64>(1)? as u64,
                        file_path: row.get(2)?,
                        mime_type: row.get(3)?,
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

    Ok(value)
}
