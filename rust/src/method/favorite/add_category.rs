use snowid::SnowID;

use super::{get_db, rusqlite};

pub async fn add_category(category_name: &str) -> Result<(), String> {
    let db = get_db().await?;

    let gen = SnowID::new(1).map_err(|e| e.to_string())?;
    let id = gen.generate() as i64;
    let category_name = category_name.to_string();

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        let max_order: i64 = conn.query_row(
            "SELECT COALESCE(MAX(order_position), 0) FROM category",
            [],
            |row| row.get(0),
        )?;

        conn.execute(
            "INSERT INTO category (id, name, order_position) VALUES (?1, ?2, ?3)",
            rusqlite::params![id, category_name, max_order + 1],
        )?;

        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    Ok(())
}
