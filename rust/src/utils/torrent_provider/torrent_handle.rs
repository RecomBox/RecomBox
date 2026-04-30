

use librqbit::*;
use std::{error::Error, path::PathBuf};
use dashmap::DashMap;
use std::sync::{Arc, LazyLock};
use librqbit::ManagedTorrent;
use librqbit::api::TorrentIdOrHash;
use serde::{Deserialize, Serialize};
use flutter_rust_bridge::frb;


use super::torrent_session::TorrentSession;


static WATCH_TORRENT_HANDLE_MAP: LazyLock<DashMap<String, Arc<ManagedTorrent>>> = LazyLock::new(DashMap::new);
static DOWNLOAD_TORRENT_HANDLE_MAP: LazyLock<DashMap<String, Arc<ManagedTorrent>>> = LazyLock::new(DashMap::new);


#[frb(json_serializable)]
#[derive(Debug, Deserialize, Serialize, PartialEq, Eq, Clone)]
pub enum TorrentHandleMode{
    Watch,
    Download
}

impl TorrentHandleMode {
    pub fn to_string(&self) -> String {
        match self {
            TorrentHandleMode::Watch => "watch".to_string(),
            TorrentHandleMode::Download => "download".to_string()
        }
    }

    pub fn from_str(s: &str) -> TorrentHandleMode {
        match s.to_lowercase().as_str() {
            "watch" => TorrentHandleMode::Watch,
            "download" => TorrentHandleMode::Download,
            _ => TorrentHandleMode::Watch
        }
    }
}

#[frb(json_serializable)]
#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct TorrentHandle {
    pub torrent_handle_mode: TorrentHandleMode,
    pub torrent_source: String,
    pub file_id: u64,
    pub output_dir: PathBuf
}

impl TorrentHandle {
    pub async fn load(self) -> anyhow::Result<(Arc<ManagedTorrent>, bool), Box<dyn Error>>{
        let session = TorrentSession::get().await?.clone();

        let torrent_handle_map = match self.torrent_handle_mode {
            TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
            TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
        };
        
        let already_exist;

        let torrent_handle = match torrent_handle_map.get(&self.torrent_source) {
            Some(handle) => {
                let handle = handle.clone();

                let mut current = handle.only_files().unwrap_or_default();
                if !current.contains(&(self.file_id as usize)) {
                    already_exist = false;
                    current.push(self.file_id as usize);

                    let mut options = AddTorrentOptions::default();
                    options.overwrite = true;
                    options.paused = false;
                    options.only_files = Some(current);
                    options.output_folder = Some(self.output_dir.to_string_lossy().to_string());

                    TorrentHandle::free(&self.torrent_handle_mode, &self.torrent_source, false).await?;

                    let new_handle = session
                        .add_torrent(
                            AddTorrent::from_url(self.torrent_source.as_str()),
                            Some(options),
                        )
                        .await?
                        .into_handle()
                        .ok_or("Unable to convert to handle")?;


                    new_handle
                } else {
                    already_exist = true;
                    handle
                }
            },
            None => {
                already_exist = false;
                let mut options = AddTorrentOptions::default();
                options.overwrite = true;
                options.paused = false;
                options.only_files = Some(vec![self.file_id as usize]);
                options.output_folder = Some(self.output_dir.to_string_lossy().to_string());
                
                let new_handle = session
                    .add_torrent(
                        AddTorrent::from_url(self.torrent_source.as_str()),
                        Some(options),
                    )
                    .await
                    .expect("Failed to add torrent")
                    .into_handle()
                    .ok_or("Unable to convert to handle")?;
                new_handle
            }
        };


        torrent_handle_map.insert(self.torrent_source.clone(), torrent_handle.clone());
        torrent_handle.wait_until_initialized().await?;
        return Ok((torrent_handle.clone(), already_exist));

    }


    pub async fn pause_files(self, file_id: u64) -> anyhow::Result<(), Box<dyn Error>>{
        let session = TorrentSession::get().await?.clone();

        let torrent_handle_map = match self.torrent_handle_mode {
            TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
            TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
        };

        let torrent_handle = torrent_handle_map.get(&self.torrent_source)
            .ok_or("Unable to find torrent handle")?
            .clone();

        let mut current_files = torrent_handle.only_files().unwrap_or_default();
        
        current_files.retain(|x| x != &(file_id as usize));

        if current_files.is_empty() {
            TorrentHandle::free(&self.torrent_handle_mode, &self.torrent_source, false).await?;
            torrent_handle_map.remove(&self.torrent_source);
            println!("[{}:{}] Pause files success!", file!(), line!());

            return Ok(());
        }

        let mut options = AddTorrentOptions::default();
        options.overwrite = true;
        options.paused = false;
        options.only_files = Some(current_files);
        options.output_folder = Some(self.output_dir.to_string_lossy().to_string());
        TorrentHandle::free(&self.torrent_handle_mode, &self.torrent_source, false).await?;
        let new_handle = session
            .add_torrent(
                AddTorrent::from_url(self.torrent_source.as_str()),
                Some(options),
            )
            .await?
            .into_handle()
            .ok_or("Unable to convert to handle")?;
        torrent_handle_map.insert(self.torrent_source.clone(), new_handle.clone());
        new_handle.wait_until_initialized().await?;

        println!("[{}:{}] Pause files success!", file!(), line!());
        return Ok(());

    }



    pub async fn free(torrent_handle_mode: &TorrentHandleMode, torrent_source: &str, delete_files: bool) -> anyhow::Result<()>{
        let torrent_handle_map = match torrent_handle_mode {
            TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
            TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
        };
        let torrent_handle = match torrent_handle_map.get(torrent_source) {
            Some(handle) => handle.clone(),
            None => {
                println!("[{}:{}] TORRENT HANDLE NOT FOUND. -> Skip clearning.", file!(), line!());
                return Ok(());
            }
        };

        let torrent_session = TorrentSession::get().await?;
        let torrent_id = TorrentIdOrHash::Id(torrent_handle.id());

        torrent_session.delete(torrent_id, delete_files).await?;


        return Ok(());

    }

}