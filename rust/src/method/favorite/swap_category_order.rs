use super::{get_db, rusqlite};

pub async fn swap_category_order(category_id_1: u64, category_id_2: u64) -> Result<(), String> {
    let db = get_db().await?;
    let cat_id_1 = category_id_1 as i64;
    let cat_id_2 = category_id_2 as i64;

    db.call(move |conn| -> Result<(), rusqlite::Error> {
        let tx = conn.transaction()?;

        let position_1: Option<i64> = tx
            .query_row(
                "SELECT order_position FROM category WHERE id = ?1",
                rusqlite::params![cat_id_1],
                |row| row.get(0),
            )
            .ok();

        let position_2: Option<i64> = tx
            .query_row(
                "SELECT order_position FROM category WHERE id = ?1",
                rusqlite::params![cat_id_2],
                |row| row.get(0),
            )
            .ok();

        if let (Some(p1), Some(p2)) = (position_1, position_2) {
            tx.execute(
                "UPDATE category SET order_position = ?1 WHERE id = ?2",
                rusqlite::params![p2, cat_id_1],
            )?;
            tx.execute(
                "UPDATE category SET order_position = ?1 WHERE id = ?2",
                rusqlite::params![p1, cat_id_2],
            )?;
        }

        tx.commit()?;
        Ok(())
    })
    .await
    .map_err(|e| e.to_string())?;

    Ok(())
}
