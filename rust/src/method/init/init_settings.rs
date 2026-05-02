use std::fs;

use crate::utils::settings::Settings;

pub fn init_settings(settings: Settings) -> anyhow::Result<()> {
    if fs::exists(&settings.paths.temp_dir)? {
        fs::remove_dir_all(&settings.paths.temp_dir)?;
    }

    if fs::exists(&settings.paths.app_cache_dir)? {
        fs::remove_dir_all(&settings.paths.app_cache_dir)?;
    }

    return Settings::init(settings);
    
}