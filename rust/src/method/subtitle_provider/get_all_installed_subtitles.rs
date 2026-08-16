use flutter_rust_bridge::frb;
pub use recombox_subtitle_provider::manage_subtitle::get_all_installed_subtitles::GetAllInstalledSubtitlesData;
use std::path::PathBuf;


use crate::utils::settings::Settings;

#[frb(mirror(GetAllInstalledSubtitlesData))]
pub struct _GetAllInstalledSubtitlesData{
  pub source: String,
  pub id: String,
  pub subtitle_id: u64,
  pub title: String,
  pub path: String
}


pub async fn get_all_installed_subtitles() -> Result<Vec<GetAllInstalledSubtitlesData>, String> {
  let settings = Settings::get()
    .map_err(|e| e.to_string())?;

  let appdata_dir = &settings.paths.app_support_dir;
  let subtitle_directory = PathBuf::from(appdata_dir)
    .join("subtitle");


  
  let manager = recombox_subtitle_provider::manage_subtitle::SubtitleDatabaseManager{
    subtitle_directory
  };
  let result = manager.get_all_installed().await
    .map_err(|e| e.to_string())?;

  Ok(result)

}