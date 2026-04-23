
use redb::{ReadableDatabase};
use serde_json::{to_vec};



use super::{get_db, ITEM_AND_CATEGORY_TABLE, ItemInfo};

pub async fn is_in_category(item_info: ItemInfo) -> Result<bool, String> {
    let db = get_db()?;

    let read_txn = db.begin_read().map_err(|e| e.to_string())?;

    let item_cat_table = match read_txn.open_multimap_table(ITEM_AND_CATEGORY_TABLE) {
        Ok(t) => t,
        Err(_) => return Ok(false), // table missing → no categories
    };

    let serialized_item_info = to_vec(&item_info)
        .map_err(|e| e.to_string())?;

    let values = item_cat_table.get(serialized_item_info.as_slice()).map_err(|e| e.to_string())?;

    // If iterator has at least one entry, item is in a category
    Ok(values.into_iter().next().is_some())
}
