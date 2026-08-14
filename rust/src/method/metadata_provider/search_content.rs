
use recombox_metadata_provider::{
	search_content,
};
use recombox_metadata_provider::global_types::Source;


use serde::{Deserialize, Serialize};

use crate::utils::settings::Settings;


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchContentInfo{
	pub source: String,
	pub id: String,
	pub title: String,
	pub year: String,
	pub thumbnail_url: String,
}

pub async fn search_content(source: &str, search: &str, page: u64) -> Result<Vec<SearchContentInfo>, String> {

	let source = Source::from_str(source);

	let settings = Settings::get()
		.map_err(|e| e.to_string())?;

	let params = search_content::SearchContentParams{
		tmdb_token: settings.tmdb_rat_token.clone()
			.ok_or(String::from("Missing tmdb_rat_token"))?,
		source: source.clone(),
		search: search.to_owned(),
		page: page
	};


	let data = search_content::new(&params)
		.await
		.map_err(|e| e.to_string())?;

	let result: Vec<SearchContentInfo> = data.iter()
		.map(|info| SearchContentInfo {
			source: source.to_string(),
			id: info.id.to_owned(),
			title: info.title.to_owned(),
			year: info.year.to_owned(),
			thumbnail_url: info.thumbnail_url.to_owned(),
		})
		.collect();

	
	return Ok(result);
}