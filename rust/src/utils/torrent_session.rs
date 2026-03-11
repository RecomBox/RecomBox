use librqbit::Session;
use std::sync::{Arc, RwLock};


static TORRENT_SESSION: RwLock<Option<Arc<Session>>> = RwLock::new(None);

pub struct TorrentSession;

impl TorrentSession {

    pub async fn init() -> anyhow::Result<(), Box<dyn std::error::Error>>{
        let session = Session::new("tmp/downloads".into())
        .await?;

        *TORRENT_SESSION.write()? = Some(session);

        return Ok(());
    }

    pub fn get() -> Result<Arc<Session>, Box<dyn std::error::Error>> {
        let guard = TORRENT_SESSION.read()?;

        match guard.as_ref() {
            Some(session) => return Ok(session.clone()),
            None => return Err("Torrent session not initialized yet.".into())
        };
    }
    
}
