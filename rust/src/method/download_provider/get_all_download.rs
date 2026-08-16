use std::collections::HashMap;

use serde::{Deserialize, Serialize};

use super::{get_db, rusqlite};

#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct AllDownloadItemKey {
    pub source: String,
    pub id: String,
}

#[derive(Debug, Serialize, Deserialize, Eq, PartialEq, Hash, Clone)]
pub struct AllDownloadItemValue {
    pub season_index: u64,
    pub episode_index: u64,
}

pub async fn get_all_download() -> Result<HashMap<AllDownloadItemKey, Vec<AllDownloadItemValue>>, String> {
    let db = get_db().await?;

    let result = db
        .call(|conn| -> Result<HashMap<AllDownloadItemKey, Vec<AllDownloadItemValue>>, rusqlite::Error> {
            let mut stmt = conn.prepare(
                "SELECT source, item_id, season_index, episode_index FROM download",
            )?;

            let rows = stmt.query_map([], |row| {
                let source: String = row.get(0)?;
                let id: String = row.get(1)?;
                let season_index: i64 = row.get(2)?;
                let episode_index: i64 = row.get(3)?;
                Ok((source, id, season_index as u64, episode_index as u64))
            })?;

            let mut result: HashMap<AllDownloadItemKey, Vec<AllDownloadItemValue>> = HashMap::new();

            for row in rows {
                let (source, id, season_index, episode_index) = row?;

                let key = AllDownloadItemKey { source, id };
                let value = AllDownloadItemValue { season_index, episode_index };

                result.entry(key).or_insert_with(Vec::new).push(value);
            }

            Ok(result)
        })
        .await
        .map_err(|e| e.to_string())?;

    Ok(result)
}
