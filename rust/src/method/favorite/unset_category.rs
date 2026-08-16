use super::{get_db, rusqlite};

pub async fn unset_category(category_id: u64, source: &str, id: &str) -> Result<(), String> {
    let db = get_db().await?;
    let cat_id = category_id as i64;

    // First check if category exists
    let exists: bool = db
        .call(move |conn| -> Result<bool, rusqlite::Error> {
            let exists: bool = conn.query_row(
                "SELECT EXISTS(SELECT 1 FROM category WHERE id = ?1)",
                rusqlite::params![cat_id],
                |row| row.get(0),
            )?;
            Ok(exists)
        })
        .await
        .map_err(|e| e.to_string())?;

    if !exists {
        return Err(format!("Category {} does not exist", category_id));
    }

    let source_owned = source.to_string();
    let id_owned = id.to_string();

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        conn.execute(
            "DELETE FROM category_item WHERE category_id = ?1 AND source = ?2 AND item_id = ?3",
            rusqlite::params![cat_id, source_owned, id_owned],
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    Ok(())
}
