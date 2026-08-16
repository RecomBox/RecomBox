use std::path::PathBuf;
use std::fs;

use super::{get_db, rusqlite, DownloadItemKey, get_download::get_download};

use crate::utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode};
use crate::utils::settings::Settings;

pub async fn remove_download(download_item_key: &DownloadItemKey) -> Result<(), String> {
    let download_info = get_download(download_item_key).await
        .map_err(|e| e.to_string())?
        .ok_or("Download not found")
        .map_err(|e| e.to_string())?;

    let db = get_db().await?;

    let source = download_item_key.source.clone();
    let id = download_item_key.id.clone();
    let season_index = download_item_key.season_index as i64;
    let episode_index = download_item_key.episode_index as i64;

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        let tx = conn.transaction()?;

        tx.execute(
            "DELETE FROM download WHERE source = ?1 AND item_id = ?2 AND season_index = ?3 AND episode_index = ?4",
            rusqlite::params![source, id, season_index, episode_index],
        )?;

        tx.execute(
            "DELETE FROM download_status WHERE source = ?1 AND item_id = ?2 AND season_index = ?3 AND episode_index = ?4",
            rusqlite::params![source, id, season_index, episode_index],
        )?;

        tx.commit()?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    let settings = Settings::get()
        .map_err(|e| e.to_string())?;

    let file_path = PathBuf::from(settings.paths.app_support_dir.clone())
        .join("download")
        .join("data")
        .join(download_info.file_path);

    if file_path.exists() {
        fs::remove_file(file_path)
            .map_err(|e| e.to_string())?;
    };

    TorrentHandle::free(
        &TorrentHandleMode::Download,
        &download_item_key.source,
        true,
        false
    ).await.map_err(|e| e.to_string())?;

    Ok(())
}
