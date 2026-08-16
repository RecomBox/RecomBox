use super::{get_db, rusqlite};

pub async fn rename_category(category_id: u64, new_category_name: &str) -> Result<(), String> {
    let db = get_db().await?;
    let cat_id = category_id as i64;
    let new_name = new_category_name.to_string();

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        conn.execute(
            "UPDATE category SET name = ?1 WHERE id = ?2",
            rusqlite::params![new_name, cat_id],
        )?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    Ok(())
}
