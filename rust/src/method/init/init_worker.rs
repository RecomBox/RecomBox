use crate::worker;

pub async fn init_worker() -> anyhow::Result<()> {
    return worker::init().await;
    
}