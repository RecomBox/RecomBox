use redb::{ReadableDatabase, ReadableTable};
use std::collections::HashMap;


use super::{get_db, CATEGORY_TABLE, CategoryMap};

pub async fn get_all_category() -> Result<CategoryMap, String> {
    let db = get_db()?;

    let read_txn = db.begin_read()
        .map_err(|e| e.to_string())?;

    let cat_table = match read_txn.open_table(CATEGORY_TABLE) {
        Ok(t) => t,
        Err(_) => return Ok(CategoryMap(HashMap::new())),
    };

    let mut categories: CategoryMap = CategoryMap(HashMap::new());

    for entry in cat_table.iter().map_err(|e| e.to_string())? {
        let (k, v) = entry.map_err(|e| e.to_string())?;
        
        categories.0.insert(k.value(), v.value().to_string());
    }

    Ok(categories)
}
