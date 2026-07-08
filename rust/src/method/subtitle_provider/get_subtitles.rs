use std::collections::HashMap;
use flutter_rust_bridge::frb;

pub use recombox_subtitle_provider::get_subtitles::SubtitleData;

#[frb(mirror(SubtitleData))]
pub struct _SubtitleData{
  pub title: String,
  pub link: String
}


pub async fn get_subtitles(link: &str) -> anyhow::Result<HashMap<String, Vec<SubtitleData>>> {
  
  recombox_subtitle_provider::get_subtitles::new(link).await

}