
use recombox_metadata_provider::{
	view_content,
};
use recombox_metadata_provider::global_types::Source;

use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use chrono::{Utc, DateTime, Duration};
use std::path::PathBuf;
use std::fs;

use crate::utils::settings::Settings;

#[frb(json_serializable)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EpisodeInfo{
	pub source: String,
	pub title: String,
	pub thumbnail_url: String
}

#[frb(json_serializable)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ViewContentInfo {
	pub source: String,
	pub external_id: String,
    pub url: String,
    pub title: String,
	pub title_secondary: String,
    pub thumbnail_url: String,
    pub banner_url: String,
    pub contextual: Vec<String>,
    pub description: String,
    pub trailer_url: String,
    pub countdown: i64,
    pub pictures: Vec<String>,
    pub episodes: Vec<Vec<EpisodeInfo>> // Seasons -> Episodes
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cache{
	last_update: String,
	data: ViewContentInfo
}


impl Cache{
	fn save(source: &Source, id: &str, data: &ViewContentInfo) -> Result<(), String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let app_cache_dir = PathBuf::from(settings.paths.app_cache_dir.clone())
			.join("view_content_info")
			.join(source.to_string());

		fs::create_dir_all(&app_cache_dir)
			.map_err(|e| e.to_string())?;

		let file_path = app_cache_dir
			.join(format!("{}.json", id));


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

	fn load(source: &Source, id: &str) -> Result<Option<Cache>, String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let app_cache_dir = PathBuf::from(settings.paths.app_cache_dir.clone())
			.join("view_content_info")
			.join(source.to_string());

		let file_path = app_cache_dir
			.join(format!("{}.json", id));

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

pub async fn view_content(source: &str, id: &str, from_cache: bool) -> Result<ViewContentInfo, String> {

	let source = Source::from_str(source);

	if from_cache {
		match Cache::load(&source, &id) {
			Ok(Some(cache)) => {
				return Ok(cache.data);
			},
			_ => {}
		}
	}

	let source_clone = source.clone();
	let id_clone = id.to_string();

	let data = tokio::task::spawn_blocking(move || {
        tokio::runtime::Handle::current().block_on(async {
            view_content::new(&source_clone, &id_clone)
                .await
                .unwrap()
        })
    })
    .await
    .map_err(|e| e.to_string())?;


	let result: ViewContentInfo = ViewContentInfo {
		source: source.to_string(),
		external_id: data.external_id,
		url: data.url,
		title: data.title,
		title_secondary: data.title_secondary,
		thumbnail_url: data.thumbnail_url,
		banner_url: data.banner_url,
		contextual: data.contextual,
		description: data.description,
		trailer_url: data.trailer_url,
		countdown: data.countdown,
		pictures: data.pictures,
		episodes: data.episodes.iter()
			.map(|season| {
				season.iter().map(|ep| {
					EpisodeInfo {
						source: source.to_string(),
						title: ep.title.to_owned(),
						thumbnail_url: ep.thumbnail_url.to_owned()
					}
				}).collect::<Vec<EpisodeInfo>>()
			})
			.collect()
	};


	Cache::save(&source, &id,&result)?;
	
	return Ok(result);
}