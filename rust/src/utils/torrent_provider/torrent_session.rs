use librqbit::{Session, SessionOptions, dht::{PersistentDhtConfig}};
use std::{path::PathBuf, sync::{Arc, RwLock}};

use crate::utils::settings::Settings;


static TORRENT_SESSION: RwLock<Option<Arc<Session>>> = RwLock::new(None);

pub struct TorrentSession;

impl TorrentSession {

    pub async fn init() -> anyhow::Result<Arc<Session>>{
        let read_guard = TORRENT_SESSION.read()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?
            .clone();

        if let Some(session) = read_guard {
            session.stop().await;
        }

        let settings = Settings::get()?;

        let cache_session_dir = PathBuf::from(&settings.paths.app_cache_dir)
            .join("torrent_session_cache");

        if !cache_session_dir.exists() {
            std::fs::create_dir_all(&cache_session_dir)
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        }

        let dht_state_dir = PathBuf::from(&settings.paths.app_support_dir)
            .join("state");

        if !dht_state_dir.exists() {
            std::fs::create_dir_all(&dht_state_dir)
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        }

        let segments_dir = cache_session_dir.join("default");
        let dht_file = dht_state_dir.join("dht.dat");

        let dht_config = PersistentDhtConfig {
            dump_interval: Some(std::time::Duration::from_secs(60)),
            config_filename: Some(dht_file),
        };

        let session_options = SessionOptions {
            dht_config: Some(dht_config),
            ..Default::default()
        };

        let session = Session::new_with_opts(
            segments_dir,
            session_options,

        )
        .await?;

        let mut write_guard = TORRENT_SESSION.write()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        
        *write_guard = Some(session.clone());

        return Ok(session);
    }

    pub async fn get() -> anyhow::Result<Arc<Session>> {
        let guard = TORRENT_SESSION.read()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?
            .clone();


        match guard {
            Some(session) => {
                let is_cancelled = session.cancellation_token().is_cancelled();

                if is_cancelled {
                    let new_session = TorrentSession::init().await
                        .map_err(|e| anyhow::Error::msg(e.to_string()))?;
                    return Ok(new_session);
                }
                return Ok(session.clone())
            },
            None => {
                eprintln!("Error: TORRENT SESSION NOT INITIALIZED YET");
                return Err(anyhow::Error::msg("Torrent session not initialized yet."));
            }
        };
        


    }
    
}
