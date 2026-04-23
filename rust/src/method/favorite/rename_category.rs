

use super::{get_db, CATEGORY_TABLE};

pub async fn rename_category(category_id: u64, new_category_name: &str) -> Result<(), String> {
    let db = get_db()?;

    let write_txn = db.begin_write().map_err(|e| e.to_string())?;

    {
        let mut cat_table = write_txn.open_table(CATEGORY_TABLE)
            .map_err(|e| e.to_string())?;

        // Replace the existing value with the new name
        cat_table.insert(category_id, new_category_name).map_err(|e| e.to_string())?;
    }

    write_txn.commit().map_err(|e| e.to_string())?;
    Ok(())
}
