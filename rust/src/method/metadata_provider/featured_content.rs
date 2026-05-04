
use recombox_metadata_provider::{
	featured_content,
};
use recombox_metadata_provider::global_types::Source;


use serde::{Deserialize, Serialize};
use chrono::{Utc, DateTime, Duration};
use std::path::PathBuf;
use std::fs;

use crate::utils::settings::Settings;



#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FeaturedContentInfo{
	pub source: String,
	pub id: String,
	pub title: String,
	pub contextual: Vec<String>,
	pub short_description: String,
	pub banner_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cache{
	last_update: String,
	data: Vec<FeaturedContentInfo>,
}

impl Cache{
	fn save(source: &Source, data: &Vec<FeaturedContentInfo>) -> Result<(), String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let temp_dir = PathBuf::from(settings.paths.temp_dir.clone())
			.join("featured_content");

		fs::create_dir_all(&temp_dir)
			.map_err(|e| e.to_string())?;

		let file_path = temp_dir
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

		let temp_dir = PathBuf::from(settings.paths.temp_dir.clone())
			.join("featured_content");

		let file_path = temp_dir
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

pub async fn featured_content(source: &str, from_cache: bool) -> Result<Vec<FeaturedContentInfo>, String> {

	let source = Source::from_str(source);

	if from_cache {
		match Cache::load(&source) {
			Ok(Some(cache)) => {
				return Ok(cache.data);
			},
			_ => {}
		}
	}


	let data = featured_content::new(&source)
		.await
		.map_err(|e| e.to_string())?;

	let result: Vec<FeaturedContentInfo> = data.0.iter()
		.map(|info| FeaturedContentInfo {
			source: source.to_string(),
			id: info.id.to_owned(),
			title: info.title.to_owned(),
			short_description: info.short_description.to_owned(),
			contextual: info.contextual.to_owned(),
			banner_url: info.banner_url.to_owned(),
		})
		.collect();

	Cache::save(&source,&result)?;
	
	return Ok(result);
}