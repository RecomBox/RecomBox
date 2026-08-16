use std::collections::HashMap;

use super::{get_db, rusqlite, CategoryMap};

pub async fn get_all_category() -> Result<CategoryMap, String> {
    let db = get_db().await?;

    let map = db
        .call(|conn| -> Result<HashMap<u64, String>, rusqlite::Error> {
            let mut stmt = conn.prepare("SELECT id, name FROM category")?;

            let rows = stmt.query_map([], |row| {
                let id: i64 = row.get(0)?;
                let name: String = row.get(1)?;
                Ok((id as u64, name))
            })?;

            let mut map = HashMap::new();
            for row in rows {
                let (id, name) = row?;
                map.insert(id, name);
            }

            Ok(map)
        })
        .await
        .map_err(|e| e.to_string())?;

    Ok(CategoryMap(map))
}
