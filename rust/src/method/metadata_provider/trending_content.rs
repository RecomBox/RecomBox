use recombox_metadata_provider::{
	trending_content,
};
use recombox_metadata_provider::global_types::Source;


use serde::{Deserialize, Serialize};
use chrono::{Utc, DateTime, Duration};
use std::path::PathBuf;
use std::fs;

use crate::utils::settings::Settings;



#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrendingContentInfo {
  pub source: String,
	pub id: String,
	pub title: String,
	pub year: String,
	pub rating: String,
	pub thumbnail_url: String,
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cache{
	last_update: String,
	data: Vec<TrendingContentInfo>,
}

impl Cache{
	fn save(source: &Source, data: &Vec<TrendingContentInfo>) -> Result<(), String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let app_cache_dir = PathBuf::from(settings.paths.app_cache_dir.clone())
			.join("trending_content");

		fs::create_dir_all(&app_cache_dir)
			.map_err(|e| e.to_string())?;

		let file_path = app_cache_dir
			.join(format!("{}.json", source.to_string()));

		let new_cache = Cache{
			last_update: Utc::now().to_rfc3339(),
			data: data.clone(),
		};

		let data = serde_json::to_string(&new_cache)
			.map_err(|e| e.to_string())?;

		fs::write(file_path, data)
			.map_err(|e| e.to_string())?;

		return Ok(());
	}

	fn load(source: &Source) -> Result<Option<Cache>, String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let app_cache_dir = PathBuf::from(settings.paths.app_cache_dir.clone())
			.join("trending_content");

		let file_path = app_cache_dir
			.join(format!("{}.json", source.to_string()));

		let data = fs::read_to_string(file_path)
			.map_err(|e| e.to_string())?;

		let cache: Cache = serde_json::from_str(&data)
			.map_err(|e| e.to_string())?;

		let last_update = DateTime::parse_from_rfc3339(&cache.last_update)
			.map_err(|e| e.to_string())?
			.with_timezone(&Utc);

		if (Utc::now() - last_update) > Duration::hours(3) {
			return Ok(None);
		}

		return Ok(Some(cache));
	}

}

pub async fn trending_content(source: &str, from_cache: bool) -> Result<Vec<TrendingContentInfo>, String> {

	let source = Source::from_str(source);

	if from_cache {
		match Cache::load(&source) {
			Ok(Some(cache)) => {
				return Ok(cache.data);
			},
			_ => {}
		}
	}

	let settings = Settings::get()
		.map_err(|e| e.to_string())?;


	let params = trending_content::TrendingContentParams{
		tmdb_token: settings.tmdb_rat_token.clone()
			.ok_or(String::from("Missing tmdb_rat_token"))?,
		source: source.clone()
	};

	let data = trending_content::new(&params)
		.await
		.map_err(|e| 
			format!("Failed to get trending_content for source '{}', tmdb_token: {} with error: \n{}", source.to_string(), settings.tmdb_rat_token.clone().unwrap_or_default(), e.to_string())
		)?;





	let result: Vec<TrendingContentInfo> = data.iter()
		.map(|info| TrendingContentInfo {
      source: source.to_string(),
			id: info.id.to_owned(),
			title: info.title.to_owned(),
			year: info.year.to_owned(),
			rating: info.rating.to_owned(),
			thumbnail_url: info.thumbnail_url.to_owned(),
		})
		.collect();
	
	Cache::save(&source,&result)?;

	return Ok(result);
}