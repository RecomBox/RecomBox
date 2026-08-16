use std::collections::HashMap;

use super::{get_db, rusqlite, CategoryOrderMap};

pub async fn get_category_order() -> Result<CategoryOrderMap, String> {
    let db = get_db().await?;

    let map = db
        .call(|conn| -> Result<HashMap<u64, u64>, rusqlite::Error> {
            let mut stmt = conn.prepare("SELECT id, order_position FROM category")?;

            let rows = stmt.query_map([], |row| {
                let id: i64 = row.get(0)?;
                let order: i64 = row.get(1)?;
                Ok((id as u64, order as u64))
            })?;

            let mut map = HashMap::new();
            for row in rows {
                let (id, order) = row?;
                map.insert(id, order);
            }

            Ok(map)
        })
        .await
        .map_err(|e| e.to_string())?;

    Ok(CategoryOrderMap(map))
}
