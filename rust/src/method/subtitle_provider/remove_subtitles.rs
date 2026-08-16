use std::path::PathBuf;

pub use recombox_subtitle_provider::manage_subtitle::remove_installed_subtitle::{RemoveInstalledSubtitlesParams};

use crate::utils::settings::Settings;



pub async fn remove_subtitles(
  source: &str,
  id: &str,
  subtitle_id: u64
) -> anyhow::Result<(), String> {
  let settings = Settings::get()
    .map_err(|e| e.to_string())?;

  let appdata_dir = &settings.paths.app_support_dir;
  let subtitle_directory = PathBuf::from(appdata_dir)
    .join("subtitle");


  
  let manager = recombox_subtitle_provider::manage_subtitle::SubtitleDatabaseManager{
    subtitle_directory
  };

  let params = RemoveInstalledSubtitlesParams{
    source: recombox_subtitle_provider::global_types::Source::from_str(source).ok_or("Invalid source")?,
    id: id.to_string(),
    subtitle_id

  };

  let result = manager.remove_installed(&params).await
    .map_err(|e| e.to_string())?;


  Ok(result)

}