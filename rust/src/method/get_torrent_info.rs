use librqbit_core::lengths;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

use crate::utils;

#[derive(Debug)]
pub struct Files {
    pub path: Option<String>,
    pub length: Option<usize>,
    pub sha1: Option<String>
}


#[derive(Debug)]
pub struct OutputPayload {
    pub name: Option<String>,
    pub length: Option<u64>,
    pub files: Vec<Files>,
}


pub async fn get_torrent_info(torrent_file: &str) -> Result<OutputPayload, String> {

    let torrent_info = utils::get_torrent_info::new(&PathBuf::from(torrent_file))
        .await
        .map_err(|e| e.to_string())?;

    let name = match &torrent_info.name {
        Some(name) => Some(String::from_utf8_lossy(name).to_string()),
        None => None
    };

    let length = torrent_info.length;

    let files: Vec<Files> = match &torrent_info.files {
        Some(files) => files.into_iter()
            .map(|f| Files{
                path: Some(f.path.iter().map(|i| 
                    String::from_utf8_lossy(i).to_string()).collect()
                ),
                
                length: Some(f.length as usize),

                sha1: match &f.sha1 {
                    Some(sha1) => Some(String::from_utf8_lossy(sha1).to_string()),
                    None => None
                }
            }).collect(),
        None => return Err("Unable to extract files".to_string())
    };

    return Ok(OutputPayload {
        name: name,
        length: length,
        files: files
    });
}