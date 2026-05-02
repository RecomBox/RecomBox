use chrono::Utc;
use serde_json::{to_vec, from_slice};
use redb::{ReadableTableMetadata}; 

use super::{
    get_db, WATCH_STATE_TABLE, WATCH_STATE_ORDER_TABLE, 
    WatchStateKey, WatchStateValue
};

pub async fn set_watch_state(
    watch_state_key: WatchStateKey,
    watch_state_value: WatchStateValue
) -> Result<(), String> {
    let db = get_db()?;
    let max_history: u64 = 500;

    let encoded_key = to_vec(&[
        watch_state_key.source.as_str(),
        watch_state_key.id.as_str(),
        watch_state_key.season_index.to_string().as_str(),
        watch_state_key.episode_index.to_string().as_str(),
    ]).map_err(|e| e.to_string())?;

    let encoded_value = to_vec(&[
        &watch_state_value.position,
    ]).map_err(|e| e.to_string())?;


    let write_txn = db.begin_write().map_err(|e| e.to_string())?;

    {
        let mut state_table = write_txn.open_table(WATCH_STATE_TABLE).map_err(|e| e.to_string())?;
        let mut order_table = write_txn.open_table(WATCH_STATE_ORDER_TABLE).map_err(|e| e.to_string())?;

        while state_table.len().map_err(|e| e.to_string())? >= max_history {

            if let Some(oldest_entry) = order_table.pop_first().map_err(|e| e.to_string())? {
                let key_info: WatchStateKey = from_slice(oldest_entry.1.value())
                    .map_err(|e| e.to_string())?;
                
                let key_to_prune = to_vec(&[
                    key_info.source.as_str(),
                    key_info.id.as_str(),
                    key_info.season_index.to_string().as_str(),
                    key_info.episode_index.to_string().as_str(),
                ]).map_err(|e| e.to_string())?;

                state_table.remove(key_to_prune.as_slice()).map_err(|e| e.to_string())?;
            } else {
                break; 
            }
        }

        state_table.insert(encoded_key.as_slice(), encoded_value.as_slice())
            .map_err(|e| e.to_string())?;

        let timestamp = Utc::now().timestamp() as u64;
        order_table.insert(timestamp, encoded_key.as_slice())
            .map_err(|e| e.to_string())?;
    }

    write_txn.commit().map_err(|e| e.to_string())?;
    
    Ok(())
}