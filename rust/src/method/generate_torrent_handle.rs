use librqbit_core::lengths;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tokio;

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


pub async fn generate_torrent_handle(torrent_file: &str, file_id: usize) -> Result<(), String> {

    let torrent_file = PathBuf::from(torrent_file);
    tokio::spawn(async move {
        utils::generate_torrent_handle::new(&torrent_file, file_id)
            .await
            .map_err(|e| e.to_string()).unwrap();
    }).await
    .map_err(|e| e.to_string())?;

    return Ok(());
}