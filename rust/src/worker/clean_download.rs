use anyhow::anyhow;
use std::path::PathBuf;
use tokio;
use std::fs;

use crate::method::download_provider::DownloadItemKey;
use crate::method::download_provider::{
    get_all_download::get_all_download,
    get_download::get_download,
};

use crate::utils::settings::Settings;

pub async fn start() -> anyhow::Result<()>{
    tokio::spawn( async move {
        loop {
            match init().await{
                Ok(_) => {
                    println!("[{}:{}] Completed a task.", file!(), line!());
                }
                Err(e) => {
                    eprintln!("[{}:{}] Failed to spawn clean up: {}", file!(), line!(), e);
                }
            }

            tokio::time::sleep(tokio::time::Duration::from_mins(5)).await;
        }
    });

    return Ok(());
}


async fn init()-> anyhow::Result<()>{
    let all_download = get_all_download().await
        .map_err(|e| anyhow!(e))?;

    let mut keep_dirs: Vec<String> = Vec::new();

    for (key, value_list) in all_download.iter(){
        for value in value_list{
            let download_info = get_download(&DownloadItemKey { 
                source: key.source.clone(), 
                id: key.id.clone(), 
                season_index: value.season_index, 
                episode_index: value.episode_index
            })
                .await.map_err(|e| anyhow!(e))?
                .ok_or(anyhow!("Download not found - Skipping..."))?;

            let path = PathBuf::from(download_info.file_path);

            if let Some(raw_top_parent) = path.components().next() {
                let top_parent = raw_top_parent.as_os_str().to_str()
                    .ok_or(anyhow!("Unable to get top parent"))?;

                if !keep_dirs.contains(&top_parent.to_string()) {
                    keep_dirs.push(top_parent.to_string());
                }
                
            }
        }
    }

    let settings = Settings::get()
        .map_err(|e| anyhow!(e))?;

    let download_dir = PathBuf::from(&settings.paths.app_support_dir)
        .join("download")
        .join("data");


    if download_dir.exists() {
        for entry in fs::read_dir(&download_dir)? {
            let entry = entry?;
            let path = entry.path();
            
            if let Some(name_os) = path.file_name() {
                let name_str = name_os.to_string_lossy().into_owned();

                if !keep_dirs.contains(&name_str) && path.exists() {
                    if path.is_dir() {
                        fs::remove_dir_all(&path)?;
                        println!("[{}:{}] Deleted directory: {:?}", file!(), line!(), name_str);
                    } else {
                        fs::remove_file(&path)?;
                        println!("[{}:{}] Deleted file: {:?}", file!(), line!(), name_str);
                    }
                }
            }
        }
    }


    return Ok(());
}
