

use redb::{ReadableDatabase, ReadableMultimapTable};

use super::{get_db, CATEGORY_TABLE, ITEM_AND_CATEGORY_TABLE, CATEGORY_AND_ITEM_TABLE, CATEGORY_ORDER_TABLE};



pub async fn delete_category(category_id: u64) -> Result<(), String> {
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
        let mut cat_table = write_txn.open_table(CATEGORY_TABLE)
            .map_err(|e| e.to_string())?;
        let mut cat_order_table = write_txn.open_table(CATEGORY_ORDER_TABLE)
            .map_err(|e| e.to_string())?;
        let mut cat_item_table = write_txn.open_multimap_table(CATEGORY_AND_ITEM_TABLE)
            .map_err(|e| e.to_string())?;
        let mut item_cat_table = write_txn.open_multimap_table(ITEM_AND_CATEGORY_TABLE)
            .map_err(|e| e.to_string())?;

        let cat_item_result = cat_item_table.get(category_id)
            .map_err(|e| e.to_string())?;

        for item in cat_item_result {
            let item_id = item
                .map_err(|e| e.to_string())?;
            // Remove reverse link: item → category
            item_cat_table.remove(item_id.value(), category_id)
                .map_err(|e| e.to_string())?;
        }

        cat_item_table.remove_all(category_id)
            .map_err(|e| e.to_string())?;

        cat_table.remove(category_id)
            .map_err(|e| e.to_string())?;

        cat_order_table.remove(category_id)
            .map_err(|e| e.to_string())?;
    }
    write_txn.commit()
        .map_err(|e| e.to_string())?;
    
    return Ok(());
}