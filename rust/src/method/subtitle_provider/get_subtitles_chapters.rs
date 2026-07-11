use flutter_rust_bridge::frb;

pub use recombox_subtitle_provider::get_chapters::{ChapterData, GetChaptersParams};

#[frb(mirror(ChapterData))]
pub struct _ChapterData{
  pub title: String,
  pub link: String
}


pub async fn get_subtitles_chapters(imdb_id: &str, source: &str) -> anyhow::Result<Vec<ChapterData>> {
  
  let params = GetChaptersParams{
    imdb_id: imdb_id.to_string(),
    source: recombox_subtitle_provider::global_types::Source::from_str(source).ok_or(anyhow::anyhow!("Invalid source"))?,
  };

  recombox_subtitle_provider::get_chapters::new(&params).await

}