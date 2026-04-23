mod update_plugins;

pub async fn init() -> anyhow::Result<()> {
    println!("STARTING WORKER...");
    
    update_plugins::start().await?;


    println!("WORKER INITIALIZED SUCCESSFULLY.");

    return Ok(());
}