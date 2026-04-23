use std::collections::HashMap;
use redb::{ReadableDatabase};
use serde_json::{to_vec};


use super::{get_db, CATEGORY_TABLE, ITEM_AND_CATEGORY_TABLE, CategoryMap, ItemInfo};

pub async fn get_all_category_by_item_id(item_info: ItemInfo) -> Result<CategoryMap, String> {
    let db = get_db()?;

    let read_txn = db.begin_read()
        .map_err(|e| e.to_string())?;

    let item_cat_table = match read_txn.open_multimap_table(ITEM_AND_CATEGORY_TABLE) {
        Ok(t) => t,
        Err(_) => return Ok(CategoryMap(HashMap::new())),
    };
    let cat_table = match read_txn.open_table(CATEGORY_TABLE) {
        Ok(t) => t,
        Err(_) => return Ok(CategoryMap(HashMap::new())),
    };

    let mut map: HashMap<u64, String> = HashMap::new();

    let serialized_item_info = to_vec(&item_info)
        .map_err(|e| e.to_string())?;

    // MultimapValue is iterable
    let values = item_cat_table.get(serialized_item_info.as_slice()).map_err(|e| e.to_string())?;

    for entry in values {
        let cat_id = entry.map_err(|e| e.to_string())?;

        if let Some(name_val) = cat_table.get(cat_id.value()).map_err(|e| e.to_string())? {
            map.insert(cat_id.value(), name_val.value().to_string());
        }
    }

    Ok(CategoryMap(map))
}
