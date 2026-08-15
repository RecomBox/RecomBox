use std::{fs, path::PathBuf};

use crate::utils::settings::Settings;

pub fn clear_cache() -> anyhow::Result<()>{
  let settings = Settings::get()?;
  let session_cache_dir = PathBuf::from(&settings.paths.app_cache_dir)
    .join("torrent_session_cache");
  
  fs::remove_dir_all(session_cache_dir).ok();
  Ok(())
}