use std::fs;

use crate::utils::settings::Settings;

pub fn clear_cache() -> anyhow::Result<()>{
  let settings = Settings::get()?;
  let cache_dir = &settings.paths.app_cache_dir;
  fs::remove_dir_all(cache_dir).ok();
  Ok(())
}