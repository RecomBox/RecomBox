use serde_json::to_vec;
use std::path::PathBuf;
use std::fs;


use super::{get_db, DOWNLOAD_TABLE, DownloadItemKey, DOWNLOAD_STATUS_TABLE, get_download::get_download};

use crate::utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode};
use crate::utils::settings::Settings;

pub async fn remove_download(download_item_key: &DownloadItemKey) -> Result<(), String> {
    let download_info = get_download(download_item_key).await
        .map_err(|e| e.to_string())?
        .ok_or("Download not found")
        .map_err(|e| e.to_string())?;

    let db = get_db()?;
    
    let write_txn = db.begin_write()
        .map_err(|e| e.to_string())?;
    {
        let mut download_table = write_txn.open_table(DOWNLOAD_TABLE)
            .map_err(|e| e.to_string())?;
        let mut status_table = write_txn.open_table(DOWNLOAD_STATUS_TABLE)
            .map_err(|e| e.to_string())?;

        let encoded_key = to_vec(&[
            download_item_key.source.as_str(),
            download_item_key.id.as_str(),
            download_item_key.season_index.to_string().as_str(),
            download_item_key.episode_index.to_string().as_str(),
        ]).map_err(|e| e.to_string())?;

        download_table.remove(encoded_key.as_slice())
            .map_err(|e| e.to_string())?;

        status_table.remove(encoded_key.as_slice())
            .map_err(|e| e.to_string())?;
    }

    write_txn.commit()
        .map_err(|e| e.to_string())?;
    
    let settings = Settings::get()
        .map_err(|e| e.to_string())?;


    let file_path = PathBuf::from(settings.paths.app_support_dir.clone())
        .join("download")
        .join(download_item_key.source.to_string())
        .join(download_item_key.id.to_string())
        .join(download_info.file_path);

    if file_path.exists() {
        fs::remove_file(file_path)
            .map_err(|e| e.to_string())?;
    };

    TorrentHandle::free(
        &TorrentHandleMode::Download,
        &download_item_key.source,
        true
    ).await.map_err(|e| e.to_string())?;

    Ok(())
}
