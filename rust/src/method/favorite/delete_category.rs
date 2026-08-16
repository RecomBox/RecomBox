use super::{get_db, rusqlite};

pub async fn delete_category(category_id: u64) -> Result<(), String> {
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

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        let tx = conn.transaction()?;

        // category_item rows are removed automatically via ON DELETE CASCADE,
        // but this stays explicit in case foreign_keys enforcement is ever off.
        tx.execute(
            "DELETE FROM category_item WHERE category_id = ?1",
            rusqlite::params![cat_id],
        )?;
        tx.execute("DELETE FROM category WHERE id = ?1", rusqlite::params![cat_id])?;

        tx.commit()?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    return Ok(());
}
