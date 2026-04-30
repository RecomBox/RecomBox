use redb::{ReadableDatabase};
use serde_json::from_slice;

use super::{get_db, DOWNLOAD_STATUS_TABLE, DownloadItemKey, DownloadStatus};

pub async fn get_download_status(
    download_item_key: &DownloadItemKey,
) -> Result<Option<DownloadStatus>, String> {
    let db = get_db()?;
    let read_txn = db.begin_read().map_err(|e| e.to_string())?;

    let table = match read_txn.open_table(DOWNLOAD_STATUS_TABLE) {
        Ok(t) => t,
        Err(e) => {
            println!("[{}:{}] {}", file!(), line!(), e);
            return Ok(None);
        },
    };

    // Encode the key as an array (same style as add_download)
    let encoded_key = serde_json::to_vec(&[
        download_item_key.source.clone(),
        download_item_key.id.clone(),
        download_item_key.season_index.to_string(),
        download_item_key.episode_index.to_string(),
    ])
    .map_err(|e| e.to_string())?;

    // Lookup the value
    if let Some(value) = table.get(encoded_key.as_slice())
        .map_err(|e| e.to_string())?
    {
        let status_parts: Vec<String> = from_slice(value.value())
            .map_err(|e| e.to_string())?;

        let state = DownloadStatus {
            progress_size: status_parts[0].parse::<u64>().map_err(|e| e.to_string())?,
            total_size: status_parts[1].parse::<u64>().map_err(|e| e.to_string())?,
            paused: status_parts[2].parse::<bool>().map_err(|e| e.to_string())?,
            done: status_parts[3].parse::<bool>().map_err(|e| e.to_string())?,
        };

        Ok(Some(state))
    } else {
        Ok(None)
    }
}
