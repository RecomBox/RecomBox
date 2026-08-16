use std::collections::HashMap;

use super::{get_db, rusqlite, CategoryMap};

pub async fn get_all_category_by_item_id(source: &str, id: &str) -> Result<CategoryMap, String> {
    let db = get_db().await?;
    let source_owned = source.to_string();
    let id_owned = id.to_string();

    let map = db
        .call(move |conn| -> Result<HashMap<u64, String>, rusqlite::Error> {
            let mut stmt = conn.prepare(
                "SELECT c.id, c.name
                 FROM category_item ci
                 JOIN category c ON c.id = ci.category_id
                 WHERE ci.source = ?1 AND ci.item_id = ?2",
            )?;

            let rows = stmt.query_map(rusqlite::params![source_owned, id_owned], |row| {
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
