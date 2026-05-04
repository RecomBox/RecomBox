use redb::{ReadableDatabase, ReadableTable};
use serde_json::from_slice;
use std::collections::HashMap;

use serde::{Deserialize, Serialize};


use super::{get_db, DOWNLOAD_TABLE};




#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct AllDownloadItemKey{
    pub source: String,
    pub id: String,
    
}


#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct AllDownloadItemValue{
    pub season_index: u64,
    pub episode_index: u64,
}



pub async fn get_all_download() -> Result<HashMap<AllDownloadItemKey,Vec<AllDownloadItemValue>>, String> {
    let db = get_db()?;
    let read_txn = db.begin_read().map_err(|e| e.to_string())?;

    let table = match read_txn.open_table(DOWNLOAD_TABLE) {
        Ok(table) => table,
        Err(e) => {
            println!("[{}:{}] Failed to open table: {}", file!(),  line!(), e);
            return Ok(HashMap::new());
        },
    };

    let mut result: HashMap<AllDownloadItemKey, Vec<AllDownloadItemValue>> = HashMap::new();

    for entry in table.iter().map_err(|e| e.to_string())? {
        
        let (key_bytes, _value_bytes) = entry.map_err(|e| e.to_string())?;

        // Decode key array back into struct
        let key_parts: Vec<String> = from_slice(key_bytes.value())
            .map_err(|e| e.to_string())?;
        if key_parts.len() != 4 {
            return Err("Invalid key format".into());
        }
        let key = AllDownloadItemKey {
            source: key_parts[0].clone(),
            id: key_parts[1].clone(),
        };

        let value = AllDownloadItemValue {
            season_index: key_parts[2].parse::<u64>().map_err(|e| e.to_string())?,
            episode_index: key_parts[3].parse::<u64>().map_err(|e| e.to_string())?,
        };

        let mut current_value = match result.get_mut(&key){
            Some(v) => v.clone(),
            None => {
                vec![]
            }
        };
        current_value.push(value);
        result.insert(key, current_value.to_vec());
    }

    Ok(result)
}
