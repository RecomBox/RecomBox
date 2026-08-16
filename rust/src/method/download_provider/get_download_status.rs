use super::{get_db, rusqlite, DownloadItemKey, DownloadStatus};

pub async fn get_download_status(
    download_item_key: &DownloadItemKey,
) -> Result<Option<DownloadStatus>, String> {
    let db = get_db().await?;

    let source = download_item_key.source.clone();
    let id = download_item_key.id.clone();
    let season_index = download_item_key.season_index as i64;
    let episode_index = download_item_key.episode_index as i64;

    let value = db
        .call(move |conn| -> Result<Option<DownloadStatus>, rusqlite::Error> {
            let result = conn.query_row(
                "SELECT progress_size, total_size, paused, done FROM download_status
                 WHERE source = ?1 AND item_id = ?2 AND season_index = ?3 AND episode_index = ?4",
                rusqlite::params![source, id, season_index, episode_index],
                |row| {
                    Ok(DownloadStatus {
                        progress_size: row.get::<_, i64>(0)? as u64,
                        total_size: row.get::<_, i64>(1)? as u64,
                        paused: row.get(2)?,
                        done: row.get(3)?,
                    })
                },
            );

            match result {
                Ok(status) => Ok(Some(status)),
                Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
                Err(e) => Err(e),
            }
        })
        .await
        .map_err(|e| e.to_string())?;

    return Ok(value);
}
