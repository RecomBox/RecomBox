use std::path::PathBuf;

use recombox_subtitle_provider::manage_subtitle::install_subtitle::InstallSubtitleParams;

use crate::utils::settings::Settings;


pub async fn install_subtitle(
  source: &str,
  id: &str,
  language: &str,
  link: &str
) -> anyhow::Result<()> {
  let settings = Settings::get()?;

  let appdata_dir = &settings.paths.app_support_dir;
  let subtitle_directory = PathBuf::from(appdata_dir)
    .join("subtitle");


  
  let manager = recombox_subtitle_provider::manage_subtitle::SubtitleDatabaseManager{
    subtitle_directory
  };

  let params = InstallSubtitleParams{
    source: recombox_subtitle_provider::global_types::Source::from_str(source).ok_or(anyhow::anyhow!("Invalid source"))?,
    id: id.to_string(),
    language: language.to_string(),
    link: link.to_string(),
  };

  manager.install(&params).await

}