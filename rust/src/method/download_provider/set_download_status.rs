use serde_json::to_vec;
use std::path::PathBuf;


use super::{get_db, DOWNLOAD_STATUS_TABLE, DownloadItemKey, DownloadStatus, get_download_status::get_download_status};
use crate::{method::download_provider::get_download::get_download, utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode}};
use crate::utils::settings::Settings;

pub async fn set_download_status(
    download_item_key: &DownloadItemKey,
    download_status: &DownloadStatus,
    apply_progress: bool
) -> Result<(), String> {
    let db = get_db()?;
    let write_txn = db.begin_write().map_err(|e| e.to_string())?;

    {
        let mut table = write_txn.open_table(DOWNLOAD_STATUS_TABLE)
            .map_err(|e| e.to_string())?;

        let current_download_status = get_download_status(download_item_key)
            .await.map_err(|e| e.to_string())?
            .unwrap_or(DownloadStatus { progress_size: 0, total_size: 1, paused: false, done: false });

        let progress_size;
        let total_size;

        if apply_progress {
            progress_size = download_status.progress_size;
            total_size = download_status.total_size;
        }else{
            progress_size = current_download_status.progress_size;
            total_size = current_download_status.total_size;
        }

        // Encode the key as an array
        let encoded_key = to_vec(&[
            download_item_key.source.clone(),
            download_item_key.id.clone(),
            download_item_key.season_index.to_string(),
            download_item_key.episode_index.to_string(),
        ])
        .map_err(|e| e.to_string())?;

        // Encode the value as an array [paused, done]
        let encoded_value = to_vec(&[
            progress_size.to_string().as_str(),
            total_size.to_string().as_str(),
            download_status.paused.to_string().as_str(),
            download_status.done.to_string().as_str(),
        ])
        .map_err(|e| e.to_string())?;

        table.insert(encoded_key.as_slice(), encoded_value.as_slice())
            .map_err(|e| e.to_string())?;
    }

    write_txn.commit().map_err(|e| e.to_string())?;

    if download_status.paused {
        let download_info = get_download(&download_item_key).await?;

        let settings = Settings::get()
            .map_err(|e| e.to_string())?;


        let output_dir = PathBuf::from(settings.paths.app_support_dir.clone())
            .join("download")
            .join(download_item_key.source.to_string())
            .join(download_item_key.id.to_string())
            .join(format!("S{}", download_item_key.season_index+1))
            .join(format!("E{}", download_item_key.season_index+1));
            

        if let Some(download_info) = download_info {
            let torrent_handle = TorrentHandle{
                torrent_handle_mode: TorrentHandleMode::Download,
                file_id: download_info.file_id,
                torrent_source: download_info.torrent_source.clone(),
                output_dir: output_dir
            };
            
            torrent_handle.pause_files(download_info.file_id).await
                .map_err(|e| e.to_string())?;


        }
    }
    Ok(())
}
