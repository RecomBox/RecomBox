use std::fs;

use crate::{method::clear_cache::clear_cache, utils::settings::Settings};

pub fn init_settings(settings: Settings) -> anyhow::Result<()> {
    if fs::exists(&settings.paths.temp_dir)? {
        fs::remove_dir_all(&settings.paths.temp_dir)?;
    }

    Settings::init(settings)?;

    
    clear_cache()?;
    Ok(())
}