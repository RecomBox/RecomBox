

use librqbit::*;
use std::io::SeekFrom;
use tokio::io::AsyncSeekExt;
use tokio_util::io::ReaderStream;
use std::{error::Error, path::PathBuf};
use futures::Stream;
use bytes::Bytes;
use dashmap::DashMap;

use serde_json::{to_string};

use std::sync::{RwLock, Arc, LazyLock};

use super::torrent_session::TorrentSession;
use super::torrent_handle::TORRENT_HANDLE;

pub async fn new(torrent_file: &PathBuf, file_id: usize) -> Result<(), Box<dyn Error>>{
    let session = TorrentSession::get()?;

    let mut options = AddTorrentOptions::default();
    options.overwrite = true;
    options.paused = false;
    options.only_files = Some(vec![file_id]);

    let torrent_handle = match TORRENT_HANDLE.get(torrent_file)
    .and_then(|m| 
        m
        .get(&file_id)
        .map(|h| h.value().clone())
    ) {
        Some(handle) => handle.clone(),
        None => {
            let new_handle = session
                .add_torrent(
                    AddTorrent::from_local_filename(torrent_file.to_str().ok_or("Unable to convert to str")?)?,
                    Some(options),
                )
                .await
                .expect("Failed to add torrent")
                .into_handle()
                .ok_or("Unable to convert to handle")?;
            
            if let Some(handle) = TORRENT_HANDLE.get(torrent_file) {
                handle.insert(file_id, new_handle.clone());
            }else{
                TORRENT_HANDLE.insert(torrent_file.clone(), DashMap::new());
                if let Some(handle) = TORRENT_HANDLE.get(torrent_file) {
                    handle.insert(file_id, new_handle.clone());
                }
            }
            
            new_handle
        }
    };
    
    torrent_handle.wait_until_initialized().await?;
    
    return Ok(());

}