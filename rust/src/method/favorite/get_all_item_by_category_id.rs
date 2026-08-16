use super::{get_db, rusqlite, FavoriteItemInfo};

pub async fn get_all_item_by_category_id(category_id: u64) -> Result<Vec<FavoriteItemInfo>, String> {
    let db = get_db().await?;
    let cat_id = category_id as i64;

    let items = db
        .call(move |conn| -> Result<Vec<FavoriteItemInfo>, rusqlite::Error> {
            let mut stmt = conn.prepare(
                "SELECT source, item_id FROM category_item WHERE category_id = ?1",
            )?;

            let rows = stmt.query_map(rusqlite::params![cat_id], |row| {
                Ok(FavoriteItemInfo {
                    source: row.get(0)?,
                    id: row.get(1)?,
                })
            })?;

            let mut items = Vec::new();
            for row in rows {
                items.push(row?);
            }

            Ok(items)
        })
        .await
        .map_err(|e| e.to_string())?;

    Ok(items)
}
