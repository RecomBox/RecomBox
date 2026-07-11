

use librqbit::*;
use std::{error::Error, path::PathBuf};
use dashmap::DashMap;
use std::sync::{Arc, LazyLock};
use librqbit::ManagedTorrent;
use librqbit::api::TorrentIdOrHash;
use serde::{Deserialize, Serialize};
use std::fs;



use crate::utils::get_dir_size;
use crate::utils::settings::Settings;

use super::torrent_session::TorrentSession;
use super::serialize_torrent_source;



static WATCH_TORRENT_HANDLE_MAP: LazyLock<DashMap<String, Arc<ManagedTorrent>>> = LazyLock::new(DashMap::new);
static DOWNLOAD_TORRENT_HANDLE_MAP: LazyLock<DashMap<String, Arc<ManagedTorrent>>> = LazyLock::new(DashMap::new);



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


#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct TorrentHandle {
    pub torrent_handle_mode: TorrentHandleMode,
    pub torrent_source: String,
    pub file_id: u64,
    pub output_dir: PathBuf
}

impl TorrentHandle {
    pub async fn load(self) -> anyhow::Result<(Arc<ManagedTorrent>, bool), Box<dyn Error>>{
        if self.torrent_handle_mode == TorrentHandleMode::Watch{
            let settings = Settings::get()?;
            let max_cache_size = settings.max_cache_size.unwrap_or(5368709120); // 5GB default
            let current_cache_size = get_dir_size::new(&settings.paths.app_cache_dir);
            
            if current_cache_size > max_cache_size{
                let session_dir = PathBuf::from(&settings.paths.app_cache_dir)
                    .join("torrent_session_cache");
                fs::remove_dir_all(&session_dir).ok();

                let torrent_files_dir = PathBuf::from(&settings.paths.app_cache_dir)
                    .join("torrent_files");
                fs::remove_dir_all(&torrent_files_dir).ok();
            }
            
        }

        let session = TorrentSession::get().await?.clone();

        let already_exist;

        let owned_handle = {
            let torrent_handle_map = match self.torrent_handle_mode {
                TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
                TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
            };
            match torrent_handle_map.get(&self.torrent_source){
                Some(handle) => Some(handle.value().clone()),
                None => None
            }
        };

        let torrent_handle = match owned_handle {
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

                    TorrentHandle::free(&self.torrent_handle_mode, &self.torrent_source, false, false).await?;

                    let new_handle = session
                        .add_torrent(
                            serialize_torrent_source::new(self.torrent_source.as_str(), true).await?,
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
                        serialize_torrent_source::new(self.torrent_source.as_str(), true).await?,
                        Some(options),
                    )
                    .await
                    .expect("Failed to add torrent")
                    .into_handle()
                    .ok_or("Unable to convert to handle")?;
                new_handle
            }
        };

        {
            let torrent_handle_map = match self.torrent_handle_mode {
                TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
                TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
            };
            torrent_handle_map.insert(self.torrent_source.clone(), torrent_handle.clone());
        }
        return Ok((torrent_handle.clone(), already_exist));

    }


    pub async fn pause_file(self, file_id: u64) -> anyhow::Result<(), Box<dyn Error>>{
        let session = TorrentSession::get().await?.clone();

        

        let torrent_handle = match {
            let torrent_handle_map = match self.torrent_handle_mode {
                TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
                TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
            };
            
            match torrent_handle_map.get(&self.torrent_source){
                Some(handle) => Some(handle.value().clone()),
                None => None
            }
        } {
            Some(handle) => handle.clone(),
            None => {
                println!("[{}:{}] TORRENT HANDLE NOT FOUND. -> Skip clearning.", file!(), line!());
                return Ok(());
            }
        };
        

        let mut current_files = torrent_handle.only_files().unwrap_or_default();
        
        current_files.retain(|x| x != &(file_id as usize));

        if current_files.is_empty() {
            TorrentHandle::free(&self.torrent_handle_mode, &self.torrent_source, false, false).await?;
            println!("[{}:{}] Pause files success!", file!(), line!());
            return Ok(());
        }

        let mut options = AddTorrentOptions::default();
        options.overwrite = true;
        options.paused = false;
        options.only_files = Some(current_files);
        options.output_folder = Some(self.output_dir.to_string_lossy().to_string());
        TorrentHandle::free(&self.torrent_handle_mode, &self.torrent_source, false, false).await?;
        let new_handle = session
            .add_torrent(
                serialize_torrent_source::new(self.torrent_source.as_str(), true).await?,
                Some(options),
            )
            .await?
            .into_handle()
            .ok_or("Unable to convert to handle")?;
        
        {
            let torrent_handle_map = match self.torrent_handle_mode {
                TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
                TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
            };
            torrent_handle_map.insert(self.torrent_source.clone(), new_handle.clone());
        }
        
        new_handle.wait_until_initialized().await?;

        println!("[{}:{}] Pause files success!", file!(), line!());
        return Ok(());

    }



    pub async fn free(
        torrent_handle_mode: &TorrentHandleMode, 
        torrent_source: &str, 
        delete_files: bool,
        check_cache_size_before_delete: bool
    ) -> anyhow::Result<()>{
        
        let torrent_handle = match {
            let torrent_handle_map = match torrent_handle_mode {
                TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
                TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
            };
            
            match torrent_handle_map.get(torrent_source){
                Some(handle) => Some(handle.value().clone()),
                None => None
            }
        } {
            Some(handle) => handle.clone(),
            None => {
                println!("[{}:{}] TORRENT HANDLE NOT FOUND. -> Skip clearning.", file!(), line!());
                return Ok(());
            }
        };
        
        

        let torrent_session = TorrentSession::get().await?;
        let torrent_id = TorrentIdOrHash::Id(torrent_handle.id());

        let mut should_delete = delete_files;

        if *torrent_handle_mode == TorrentHandleMode::Watch && check_cache_size_before_delete{
            let settings = Settings::get()?;
            let max_cache_size = settings.max_cache_size.unwrap_or(5368709120); // 5GB default
            let current_cache_size = get_dir_size::new(&settings.paths.app_cache_dir);
            should_delete = current_cache_size >= max_cache_size;
            
        }

        torrent_session.delete(torrent_id, should_delete).await?;

        {
            let torrent_handle_map = match torrent_handle_mode {
                TorrentHandleMode::Watch => &WATCH_TORRENT_HANDLE_MAP,
                TorrentHandleMode::Download => &DOWNLOAD_TORRENT_HANDLE_MAP
            };
            torrent_handle_map.remove(torrent_source);
        }
        return Ok(());

    }

}