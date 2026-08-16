use std::path::PathBuf;
use base64::{engine::general_purpose, Engine as _};
use sha2::{Sha256, Digest};
use urlencoding::encode;

use super::{get_db, rusqlite, DownloadItemKey, DownloadStatus, get_download_status::get_download_status};
use crate::{method::download_provider::get_download::get_download, utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode}};
use crate::utils::settings::Settings;

pub async fn set_download_status(
    download_item_key: &DownloadItemKey,
    download_status: &DownloadStatus,
    apply_progress: bool,
) -> Result<(), String> {
    let db = get_db().await?;

    let progress_size;
    let total_size;

    if apply_progress {
        progress_size = download_status.progress_size;
        total_size = download_status.total_size;
    } else {
        let current_download_status = get_download_status(download_item_key)
            .await.map_err(|e| e.to_string())?
            .unwrap_or(DownloadStatus { progress_size: 0, total_size: 1, paused: false, done: false });
        progress_size = current_download_status.progress_size;
        total_size = current_download_status.total_size;
    }

    let source = download_item_key.source.clone();
    let id = download_item_key.id.clone();
    let season_index = download_item_key.season_index as i64;
    let episode_index = download_item_key.episode_index as i64;
    let progress_size = progress_size as i64;
    let total_size = total_size as i64;
    let paused = download_status.paused;
    let done = download_status.done;

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        conn.execute(
            "INSERT INTO download_status
                (source, item_id, season_index, episode_index, progress_size, total_size, paused, done)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
             ON CONFLICT (source, item_id, season_index, episode_index)
             DO UPDATE SET
                progress_size = excluded.progress_size,
                total_size    = excluded.total_size,
                paused        = excluded.paused,
                done          = excluded.done",
            rusqlite::params![source, id, season_index, episode_index, progress_size, total_size, paused, done],
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    if download_status.paused {
        let download_info = get_download(&download_item_key).await?;

        if let Some(download_info) = download_info {
            let settings = Settings::get()
                .map_err(|e| e.to_string())?;

            let mut hasher = Sha256::new();
            hasher.update(download_info.torrent_source.as_bytes());
            let sha_result = hasher.finalize();

            let encoded_torent_source = encode(&general_purpose::STANDARD.encode(sha_result))
                    .to_string();

            let output_dir = PathBuf::from(settings.paths.app_support_dir.clone())
                .join("download")
                .join("data")
                .join(encoded_torent_source);

            let torrent_handle = TorrentHandle{
                torrent_handle_mode: TorrentHandleMode::Download,
                file_id: download_info.file_id,
                torrent_source: download_info.torrent_source.clone(),
                output_dir: output_dir
            };

            torrent_handle.pause_file(download_info.file_id).await
                .map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}
