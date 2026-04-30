use redb::ReadableDatabase;
use serde_json::from_slice;

use super::{get_db, DOWNLOAD_TABLE, DownloadItemValue, DownloadItemKey};

pub async fn get_download(
    download_item_key: &DownloadItemKey,
) -> Result<Option<DownloadItemValue>, String> {
    let db = get_db()?;
    let read_txn = db.begin_read().map_err(|e| e.to_string())?;

    let table = match read_txn.open_table(DOWNLOAD_TABLE) {
        Ok(table) => table,
        Err(e) => {
            println!("[{}:{}] Failed to open table: {}", file!(),  line!(), e);
            return Ok(None)
        },
    };

    // Encode the key as an array (same as add_download)
    let encoded_key = serde_json::to_vec(&[
        &download_item_key.source,
        &download_item_key.id,
        download_item_key.season_index.to_string().as_str(),
        download_item_key.episode_index.to_string().as_str(),
    ])
    .map_err(|e| e.to_string())?;

    // Lookup the value
    if let Some(value) = table.get(encoded_key.as_slice())
        .map_err(|e| e.to_string())?
    {
        // Decode back into array form
        let decoded: Vec<String> = from_slice(value.value())
            .map_err(|e| e.to_string())?;
        
        let info = DownloadItemValue {
            torrent_source: decoded[0].clone(),
            file_id: decoded[1].parse::<u64>().map_err(|e| e.to_string())?,
            file_path: decoded[2].clone(),
            mime_type: decoded[3].clone(),
        };
        Ok(Some(info))
    
    } else {
        Ok(None)
    }
}
