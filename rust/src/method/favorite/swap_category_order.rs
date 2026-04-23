use redb::{ReadableTable};

use super::{get_db, CATEGORY_ORDER_TABLE};

pub async fn swap_category_order(category_id_1: u64, category_id_2: u64) -> Result<(), String> {
    let db = get_db()?;

    let write_txn = db.begin_write().map_err(|e| e.to_string())?;

    {
        let mut cat_order_table = write_txn.open_table(CATEGORY_ORDER_TABLE) 
            .map_err(|e| e.to_string())?;

        let position_1 = cat_order_table
            .get(category_id_1)
            .map_err(|e| e.to_string())?
            .map(|v| v.value());

        let position_2 = cat_order_table
            .get(category_id_2)
            .map_err(|e| e.to_string())?
            .map(|v| v.value());

        if let (Some(p1), Some(p2)) = (position_1, position_2) {
            cat_order_table.insert(category_id_1, p2).map_err(|e| e.to_string())?;
            cat_order_table.insert(category_id_2, p1).map_err(|e| e.to_string())?;
        }
    }

    write_txn.commit().map_err(|e| e.to_string())?;
    Ok(())
}
