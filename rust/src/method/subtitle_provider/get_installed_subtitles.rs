use std::collections::HashMap;
use flutter_rust_bridge::frb;
use std::path::PathBuf;

pub use recombox_subtitle_provider::manage_subtitle::get_installed_subtitles::{GetInstalledSubtitlesData, GetInstalledSubtitlesParams};

use crate::utils::settings::Settings;

#[frb(mirror(GetInstalledSubtitlesData))]
pub struct _GetInstalledSubtitlesData{
  pub title: String,
  pub path: String
}


pub async fn get_installed_subtitles(
  source: &str,
  id: &str,
) -> anyhow::Result<HashMap<u64, GetInstalledSubtitlesData>, String> {
  let settings = Settings::get()
    .map_err(|e| e.to_string())?;

  let appdata_dir = &settings.paths.app_support_dir;
  let subtitle_directory = PathBuf::from(appdata_dir)
    .join("subtitle");


  
  let manager = recombox_subtitle_provider::manage_subtitle::SubtitleDatabaseManager{
    subtitle_directory
  };

  let params = GetInstalledSubtitlesParams{
    source: recombox_subtitle_provider::global_types::Source::from_str(source).ok_or("Invalid source".to_string())?,
    id: id.to_string(),
  };

  let result = manager.get_installed(&params).await
    .map_err(|e| e.to_string())?;

  Ok(result)

}