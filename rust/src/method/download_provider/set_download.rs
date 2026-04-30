use serde_json::{to_vec};

use super::{get_db, DOWNLOAD_TABLE, DownloadItemKey, DownloadItemValue};


pub async fn set_download(download_item_key: &DownloadItemKey, download_item_value: &DownloadItemValue) -> Result<(), String> {
    
    let db = get_db()?;
    
    let write_txn = db.begin_write()
        .map_err(|e| e.to_string())?;

    {
        let mut table = write_txn.open_table( DOWNLOAD_TABLE)
            .map_err(|e| e.to_string())?;

        let encoded_key = to_vec(&[
            download_item_key.source.as_str(),
            download_item_key.id.as_str(),
            download_item_key.season_index.to_string().as_str(),
            download_item_key.episode_index.to_string().as_str(),
        ])
            .map_err(|e| e.to_string())?;

        let encoded_value = to_vec(&[
            &download_item_value.torrent_source,
            download_item_value.file_id.to_string().as_str(),
            &download_item_value.file_path,
            &download_item_value.mime_type,
        ])
            .map_err(|e| e.to_string())?;


        table.insert(encoded_key.as_slice(), encoded_value.as_slice())
            .map_err(|e| e.to_string())?;

    }
    write_txn.commit()
        .map_err(|e| e.to_string())?;
    
    return Ok(());
}