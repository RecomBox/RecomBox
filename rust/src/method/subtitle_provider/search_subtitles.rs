use flutter_rust_bridge::frb;

pub use recombox_subtitle_provider::search::{SearchData, SearchParams};


#[frb(mirror(SearchData))]
pub struct _SearchData{
  pub title: String,
  pub poster_url: String,
  pub link: String
}

pub async fn search_subtitles(imdb_id: &str, source: &str) -> anyhow::Result<Option<SearchData>> {
  
  let params = SearchParams {
    imdb_id: imdb_id.to_string(),
    source: recombox_subtitle_provider::global_types::Source::from_str(source).ok_or(anyhow::anyhow!("Invalid source"))?,
  };
 
  recombox_subtitle_provider::search::new(&params).await

}