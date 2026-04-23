
use redb::{ReadableDatabase};
use serde_json::from_slice;


use super::{get_db, CATEGORY_AND_ITEM_TABLE, ItemInfo};

pub async fn get_all_item_by_category_id(category_id: u64) -> Result<Vec<ItemInfo>, String> {
    let db = get_db()?;

    let read_txn = db.begin_read()
        .map_err(|e| e.to_string())?;

    let cat_item_table = match read_txn.open_multimap_table(CATEGORY_AND_ITEM_TABLE) {
        Ok(t) => t,
        Err(_) => return Ok(Vec::new()),
    };

    let mut items: Vec<ItemInfo> = Vec::new();

    // MultimapValue is iterable
    let values = cat_item_table.get(&category_id).map_err(|e| e.to_string())?;

    for entry in values {
        let item_val = entry.map_err(|e| e.to_string())?;
        let raw_bytes = item_val.value();

        match from_slice::<ItemInfo>(raw_bytes) {
            Ok(item_info) => items.push(item_info),
            Err(e) => return Err(e.to_string()),
        }
    }

    Ok(items)
}
