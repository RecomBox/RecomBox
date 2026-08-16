use super::{get_db, rusqlite};

pub async fn is_in_category(source: &str, id: &str) -> Result<bool, String> {
    let db = get_db().await?;
    let source_owned = source.to_string();
    let id_owned = id.to_string();

    let exists = db
        .call(move |conn| -> Result<bool, rusqlite::Error> {
            let exists: bool = conn.query_row(
                "SELECT EXISTS(SELECT 1 FROM category_item WHERE source = ?1 AND item_id = ?2)",
                rusqlite::params![source_owned, id_owned],
                |row| row.get(0),
            )?;
            Ok(exists)
        })
        .await
        .map_err(|e| e.to_string())?;

    Ok(exists)
}
