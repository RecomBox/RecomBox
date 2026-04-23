use redb::{ReadableTable};
use snowid::SnowID;

use super::{get_db, CATEGORY_TABLE, CATEGORY_ORDER_TABLE};


pub async fn add_category(category_name: &str) -> Result<(), String> {
    let db = get_db()?;
    
    let write_txn = db.begin_write()
        .map_err(|e| e.to_string())?;

    {
        let mut cat_table = write_txn.open_table(CATEGORY_TABLE)
            .map_err(|e| e.to_string())?;
        let mut cat_order_table = write_txn.open_table(CATEGORY_ORDER_TABLE)
            .map_err(|e| e.to_string())?;

        // -> Generate ID and add to category table
        let gen = SnowID::new(1)
            .map_err(|e| e.to_string())?;
        let id = gen.generate();

        cat_table.insert(id, category_name)
            .map_err(|e| e.to_string())?;
        // <-


        // -> Find max order position and add category into next positon

        let cat_order_result = cat_order_table.iter()
            .map_err(|e| e.to_string())?;

        let mut max_order_position: u64 = 0;

        for entry in cat_order_result{
            let (_, v) = entry
                .map_err(|e| e.to_string())?;

            if v.value() > max_order_position {
                max_order_position = v.value();
            }
        }
        max_order_position+=1;

        cat_order_table.insert(id, max_order_position)
            .map_err(|e| e.to_string())?;

        // <-

    }
    write_txn.commit()
        .map_err(|e| e.to_string())?;
    
    return Ok(());
}