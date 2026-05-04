use std::{sync::{Arc, Mutex}};
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};

use std::path::PathBuf;

static SETTIGNS: Lazy<Mutex<Option<Arc<Settings>>>> = Lazy::new(|| Mutex::new(None));


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    pub port: u32,
    pub paths: Paths,
    pub version: String
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Paths {
    pub app_support_dir: String,
    pub app_cache_dir: String,
    pub temp_dir: String,
}


impl Settings {
    pub fn temp_init() -> anyhow::Result<()> {
        let temp_dir = PathBuf::from("recombox_temp");

        std::fs::create_dir_all(&temp_dir).unwrap();

        let temp_settings = Settings {
            port: 0,
            paths: Paths {
                app_support_dir: temp_dir.join("app_support_dir").to_string_lossy().to_string(),
                app_cache_dir: temp_dir.join("app_cache_dir").to_string_lossy().to_string(),
                temp_dir: temp_dir.join("temp_dir").to_string_lossy().to_string(),
            },
            version: "0.0.1".to_string(),
        };
        let mut guard = SETTIGNS.lock()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        *guard = Some(Arc::new(temp_settings));

        return Ok(());
    }

    pub fn init(settings: Settings) -> anyhow::Result<()> {
        let mut guard = SETTIGNS.lock()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        *guard = Some(Arc::new(settings));
        return Ok(());
    }
    
    pub fn get() -> anyhow::Result<Arc<Settings>> {
        let guard = SETTIGNS.lock()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;

        match guard.as_ref() {
            Some(settings) => return Ok(settings.clone()),
            None => return Err(anyhow::Error::msg("Settings not initialized yet."))
        }
    }
}


