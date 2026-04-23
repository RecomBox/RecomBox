use redb::{ReadableDatabase};
use serde_json::{to_vec};

use super::{get_db, CATEGORY_TABLE, ITEM_AND_CATEGORY_TABLE, CATEGORY_AND_ITEM_TABLE, ItemInfo};

pub async fn unset_category(category_id: u64, item_info: ItemInfo) -> Result<(), String> {
    let db = get_db()?;

    // First check if category exists
    {
        let read_txn = db.begin_read()
            .map_err(|e| e.to_string())?;
        let cat_table = read_txn.open_table(CATEGORY_TABLE)
            .map_err(|e| e.to_string())?;
        let result = cat_table.get(category_id)
            .map_err(|e| e.to_string())?;
        if result.is_none() {
            return Err(format!("Category {} does not exist", category_id));
        }
    }

    let write_txn = db.begin_write()
        .map_err(|e| e.to_string())?;

    {
        let mut cat_item_table = write_txn.open_multimap_table(CATEGORY_AND_ITEM_TABLE)
            .map_err(|e| e.to_string())?;
        let mut item_cat_table = write_txn.open_multimap_table(ITEM_AND_CATEGORY_TABLE)
            .map_err(|e| e.to_string())?;

        let serialized_item_info = to_vec(&item_info)
            .map_err(|e| e.to_string())?;

        // Remove the specific mapping
        cat_item_table.remove(category_id, &serialized_item_info.as_slice())
            .map_err(|e| e.to_string())?;

        item_cat_table.remove(&serialized_item_info.as_slice(), category_id)
            .map_err(|e| e.to_string())?;
    }

    write_txn.commit()
        .map_err(|e| e.to_string())?;

    Ok(())
}
