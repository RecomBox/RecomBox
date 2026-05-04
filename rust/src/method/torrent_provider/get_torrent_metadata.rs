
use serde::{Deserialize, Serialize};




use crate::utils::torrent_provider::get_torrent_metadata;


#[derive(Debug, Deserialize, Serialize)]
pub struct FileInfo {
    pub id: usize,
    pub path: Option<String>,
    pub length: Option<usize>,
    pub sha1: Option<String>
}


#[derive(Debug, Deserialize, Serialize)]
pub struct TorrentMetadata {
    pub name: Option<String>,
    pub length: Option<u64>,
    pub files: Vec<FileInfo>,
}


pub async fn get_torrent_metadata(torrent_source: String) -> Result<TorrentMetadata, String> {
    
    let torrent_info = tokio::task::spawn_blocking(move || {
        tokio::runtime::Handle::current().block_on(async {
            get_torrent_metadata::new(&torrent_source)
            .await.unwrap()
        })
    })
    .await
    .map_err(|e| e.to_string())?;

    let name = match &torrent_info.name {
        Some(name) => Some(String::from_utf8_lossy(name).to_string()),
        None => None
    };

    let length = torrent_info.length;

    let files: Vec<FileInfo> = match &torrent_info.files {
        Some(files) => files.into_iter().enumerate()
            .map(|(k, f)| FileInfo{
                id: k,
                path: Some(f.path.iter().map(|i| 
                    String::from_utf8_lossy(i).to_string()).collect()
                ),
                
                length: Some(f.length as usize),

                sha1: match &f.sha1 {
                    Some(sha1) => Some(String::from_utf8_lossy(sha1).to_string()),
                    None => None
                }
            }).collect(),
        None => {
            // Single-file torrent
            if let (Some(name), Some(length)) = (&torrent_info.name, torrent_info.length) {
                vec![FileInfo {
                    id: 0,
                    path: Some(String::from_utf8_lossy(name).to_string()),
                    length: Some(length as usize),
                    sha1: None,
                }]
            } else {
                // Neither files nor length → invalid torrent
                return Err("Torrent metadata contains no files or length".to_string());
            }
        }
    };

    return Ok(TorrentMetadata {
        name: name,
        length: length,
        files: files
    });
}