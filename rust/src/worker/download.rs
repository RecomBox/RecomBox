use anyhow;
use dashmap::DashMap;
use librqbit::ManagedTorrent;
use recombox_plugin_provider::manage_plugin::get_plugin_info;
use redb::{TableDefinition, ReadableDatabase, ReadableTable};
use std::num::NonZeroU32;
use std::sync::{RwLock, Arc};
use once_cell::sync::Lazy;
use std::fs;
use redb::Database;
use std::path::PathBuf;
use chrono::{Utc, DateTime};
use recombox_metadata_provider::global_types::Source;
use tokio;
use semver;
use base64::{engine::general_purpose, Engine as _};
use sha2::{Sha256, Digest};
use urlencoding::encode;

use crate::method::download_provider::get_download_status::get_download_status;
use crate::method::download_provider::set_download_status::set_download_status;
use crate::method::download_provider::set_download::set_download;
use crate::method::download_provider::{DownloadItemKey, DownloadItemValue, DownloadStatus, set_download};
use crate::utils::torrent_provider::torrent_handle::{TorrentHandle, TorrentHandleMode};
use crate::method::download_provider::{
    get_all_download::get_all_download,
    get_download::get_download,
};

use crate::utils::settings::Settings;

const DOWNLOAD_PROGRESS_WATCHER_WORKER: Lazy<DashMap<DownloadItemKey, String>> = Lazy::new(|| DashMap::new());


pub async fn start() -> anyhow::Result<()>{
    tokio::spawn( async move {
        loop {
            match spawn_session().await{
                Ok(_) => {
                    println!("[{}:{}] Completed a task.", file!(), line!());
                }
                Err(e) => {
                    eprintln!("[{}:{}] Failed to spawn session: {}", file!(), line!(), e);
                }
            }

            tokio::time::sleep(tokio::time::Duration::from_secs(5)).await;
        }
    });

    return Ok(());
}



async fn spawn_session() -> anyhow::Result<()>{
    let all_download = get_all_download().await
        .map_err(|e| anyhow::Error::msg(e.to_string()))?;

    for (key, value) in all_download {
        for value_info in value {
            let download_item_key = DownloadItemKey { 
                source: key.source.clone(), 
                id: key.id.clone(), 
                season_index: value_info.season_index, 
                episode_index: value_info.episode_index
            };
            let current_download_status = get_download_status(&download_item_key).await.map_err(|e| anyhow::Error::msg(e.to_string()))?.unwrap_or(
                DownloadStatus { progress_size: 0, total_size: 1, paused: false, done: false }
            );

            if current_download_status.done || current_download_status.paused {continue};

            
            let download_info = get_download(&download_item_key).await
                .map_err(|e| anyhow::Error::msg(e.to_string()))?
                .ok_or(anyhow::Error::msg("Unable to find download info"))?;

            let settings = Settings::get()?;

            let mut hasher = Sha256::new();
            hasher.update(download_info.torrent_source.as_bytes());
            let sha_result = hasher.finalize();
            let encoded_torent_source = encode(&general_purpose::STANDARD.encode(sha_result))
                .to_string();

            let output_dir = PathBuf::from(settings.paths.app_support_dir.clone())
                .join("download")
                .join(key.source.to_string())
                .join(key.id.to_string())
                .join(encoded_torent_source);
                
            let new_torrent_handle = TorrentHandle {
                torrent_handle_mode: TorrentHandleMode::Download,
                torrent_source: download_info.torrent_source.clone(),
                file_id: download_info.file_id,
                output_dir: output_dir,
            };

            let (torrent_handle, _) = new_torrent_handle.load().await
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;

            let exist_progress_watcher = match DOWNLOAD_PROGRESS_WATCHER_WORKER.get(&download_item_key) {
                Some(_) => true,
                None => false,
            };

            if !exist_progress_watcher && !current_download_status.paused && !current_download_status.done {
                let key_clone = key.clone();

                DOWNLOAD_PROGRESS_WATCHER_WORKER.insert(download_item_key.clone(), String::from(""));

                tokio::spawn(async move {
                    match spawn_progress_watcher(
                        torrent_handle.clone(), 
                        DownloadItemKey { 
                            source: key_clone.source.clone(), 
                            id: key_clone.id.clone(), 
                            season_index: value_info.season_index, 
                            episode_index: value_info.episode_index
                        },
                        download_info
                    ).await {
                        Ok(_) => {}
                        Err(e) => {
                            eprintln!("[{}:{}] Failed to spawn session: {}", file!(), line!(), e);
                        }
                    }
                    DOWNLOAD_PROGRESS_WATCHER_WORKER.remove(&download_item_key);
                });
                
            }
            


        }
    }

    return Ok(());
}


async fn spawn_progress_watcher(
    torrent_handle: Arc<ManagedTorrent>,
    download_item_key: DownloadItemKey,
    mut download_item_value: DownloadItemValue
) -> anyhow::Result<()>{
    
    loop {
        tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        
        let download_info = match get_download(&download_item_key).await.map_err(|e| anyhow::Error::msg(e.to_string()))?{
            Some(info) => info,
            None => {
                println!("[{}:{}] Download not found - Skipping..", file!(), line!());
                break;
            }
        };

        let stats = torrent_handle.stats();
        if let Some(metadata) = torrent_handle.metadata.load().clone() {

            let file = metadata.file_infos.get(download_item_value.file_id as usize)
                .ok_or(anyhow::Error::msg("Unable to find file"))?;

            let downloaded = stats.file_progress.get(download_item_value.file_id as usize ).copied().unwrap_or(0);
            let total = file.len;

            let current_download_status = get_download_status(&download_item_key).await
                .map_err(|e| anyhow::Error::msg(e.to_string()))?.unwrap_or(
                DownloadStatus { progress_size: 0, total_size: 1, paused: false, done: false }
            );
            if current_download_status.paused || current_download_status.done {break;}
            if total == 0 || downloaded == 0 {continue;}

            let mut hasher = Sha256::new();
            hasher.update(download_info.torrent_source.as_bytes());
            let sha_result = hasher.finalize();
            let encoded_torent_source = encode(&general_purpose::STANDARD.encode(sha_result))
                .to_string();

            let file_path = PathBuf::from(encoded_torent_source)
                .join(&file.relative_filename);
            download_item_value.file_path = file_path.to_string_lossy().to_string();

            // println!("{:?}", download_item_value);
            set_download(&download_item_key, &download_item_value).await
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;

            set_download_status(
                &download_item_key,
                &DownloadStatus{
                    progress_size: downloaded,
                    total_size: total,
                    paused: current_download_status.paused,
                    done: downloaded == total
                },
                true
            ).await.map_err(|e| anyhow::Error::msg(e.to_string()))?;

            if downloaded == total || current_download_status.paused{
                break;
            }
        
        }
        
    }
    

    return Ok(());
}

