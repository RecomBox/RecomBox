
use recombox_metadata_provider::{
	search_content,
};
use recombox_metadata_provider::global_types::Source;


use serde::{Deserialize, Serialize};


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchContentInfo{
	pub source: String,
	pub id: String,
	pub title: String,
	pub year: String,
	pub rank: Option<u64>,
	pub thumbnail_url: String,
}

pub async fn search_content(source: &str, search: &str, sort: u64, page: u64) -> Result<Vec<SearchContentInfo>, String> {

	let source = Source::from_str(source);

	let data = search_content::new(&source, search, sort, page)
		.await
		.map_err(|e| e.to_string())?;

	let result: Vec<SearchContentInfo> = data.0.iter()
		.map(|info| SearchContentInfo {
			source: source.to_string(),
			id: info.id.to_owned(),
			title: info.title.to_owned(),
			year: info.year.to_owned(),
			rank: info.rank,
			thumbnail_url: info.thumbnail_url.to_owned(),
		})
		.collect();

	
	return Ok(result);
}