use std::{sync::{Arc, Mutex}};
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use serde_json::{to_string};
use flutter_rust_bridge::frb;

use std::path::PathBuf;

static SETTIGNS: Lazy<Mutex<Option<Arc<Settings>>>> = Lazy::new(|| Mutex::new(None));

#[frb(json_serializable)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    pub port: u32,
    pub paths: Paths,
    pub version: String,
    pub max_cache_size: Option<u64>,
    pub tmdb_rat_token: Option<String>,
}

#[frb(json_serializable)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Paths {
    pub app_config_dir: String,
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
                app_config_dir: temp_dir.join("app_config_dir").to_string_lossy().to_string(),
                app_support_dir: temp_dir.join("app_support_dir").to_string_lossy().to_string(),
                app_cache_dir: temp_dir.join("app_cache_dir").to_string_lossy().to_string(),
                temp_dir: temp_dir.join("temp_dir").to_string_lossy().to_string(),
            },
            max_cache_size: Some(5368709120),
            version: "0.0.1".to_string(),
            tmdb_rat_token: None
        };
        let mut guard = SETTIGNS.lock()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        *guard = Some(Arc::new(temp_settings));

        return Ok(());
    }

    pub fn init(mut settings: Settings) -> anyhow::Result<()> {
        let config_dir = PathBuf::from(&settings.paths.app_config_dir);

        if !config_dir.exists() {
            std::fs::create_dir_all(&config_dir)
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        }

        let setting_file = config_dir.join("settings.json");

        // load from file
        if setting_file.exists() {
            let saved_settings = match {
                let data = std::fs::read_to_string(&setting_file)
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;
                serde_json::from_str::<Settings>(&data)
                    .map_err(|e| anyhow::Error::msg(e.to_string()))
            } {
                Ok(settings) => settings,

                Err(e) => {
                    eprintln!("[{}:{}] Error: {}", file!(), line!() ,e);
                    settings.clone()
                }
            };

            if saved_settings.tmdb_rat_token.as_ref().and_then(|f| Some(!f.is_empty())).unwrap_or(false) {
                settings.tmdb_rat_token = saved_settings.tmdb_rat_token.clone();
            }
            settings.paths.app_cache_dir = saved_settings.paths.app_cache_dir.clone();
            settings.paths.app_support_dir = saved_settings.paths.app_support_dir.clone();
            
        }

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

    pub fn set(settings: Settings) -> anyhow::Result<()> {
        let config_dir = PathBuf::from(&settings.paths.app_config_dir);

        if !config_dir.exists() {
            std::fs::create_dir_all(&config_dir)
                .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        }

        let setting_file = config_dir.join("settings.json");

        std::fs::write(&setting_file, to_string(&settings)?)
            .map_err(|e| anyhow::anyhow!(e))?;

        let mut guard = SETTIGNS.lock()
            .map_err(|e| anyhow::Error::msg(e.to_string()))?;
        *guard = Some(Arc::new(settings));
        return Ok(());
    }
}


