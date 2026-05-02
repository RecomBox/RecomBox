use anyhow::{Context, Result};
use serde_json::{to_vec, from_slice};
use redb::{ReadableDatabase};

use super::{get_db, WATCH_STATE_TABLE, WatchStateKey, WatchStateValue};

pub fn get_watch_state(
    watch_state_key: WatchStateKey
) -> Result<Option<WatchStateValue>> {
    let db = get_db().map_err(|e| anyhow::anyhow!(e))?;
    
    let read_txn = db.begin_read()
        .context("Failed to begin read transaction")?;

    let table = match read_txn.open_table(WATCH_STATE_TABLE)
        .context("Failed to open table") {
            Ok(table) => table,
            Err(_) => return Ok(None),
        };

    let encoded_key = to_vec(&[
        watch_state_key.source.as_str(),
        watch_state_key.id.as_str(),
        watch_state_key.season_index.to_string().as_str(),
        watch_state_key.episode_index.to_string().as_str(),
    ]).context("Failed to encode lookup key")?;

    let result = table.get(encoded_key.as_slice())
        .context("Database read error")?;

    match result {
        Some(guard) => {
            let encoded_value = guard.value();
            
            let decoded_vec: Vec<u64> = from_slice(encoded_value)
                .context("Failed to decode watch state value")?;

            
            return Ok(Some(WatchStateValue { 
                position: decoded_vec.get(0).copied(),
            }));
            
        },
        None => return Ok(None),
    }
}