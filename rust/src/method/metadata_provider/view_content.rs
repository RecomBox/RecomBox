
use recombox_metadata_provider::{
	view_content,
};
use recombox_metadata_provider::global_types::Source;

use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use chrono::{Utc, DateTime, Duration};
use std::path::PathBuf;
use std::fs;


use crate::method::favorite::{is_in_category::is_in_category, ItemInfo};
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
    pub episodes: Vec<Vec<EpisodeInfo>>, // Seasons -> Episodes
	pub last_watch_season_index: Option<u64>,
	pub last_watch_episode_index: Option<u64>,
	pub last_update: Option<String>,
}


impl ViewContentInfo{
	async fn get_cache_dir(source: &Source, id: &str) -> Result<PathBuf, String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let is_in_fav = is_in_category(ItemInfo { 
			source: source.to_string(), 
			id: id.to_string() 
		}).await?;

		if is_in_fav {
			let cache_dir = PathBuf::from(settings.paths.app_support_dir.clone())
				.join("favorite");
			return Ok(cache_dir);
		}else{
			
			let temp_dir = PathBuf::from(settings.paths.temp_dir.clone())
				.join("view_content_info");
			return Ok(temp_dir);

		}

	}

	async fn save_cache(source: &Source, id: &str, data: &mut ViewContentInfo) -> Result<(), String> {

		let cache_dir = ViewContentInfo::get_cache_dir(source, id).await?
			.join(source.to_string());

		fs::create_dir_all(&cache_dir)
			.map_err(|e| e.to_string())?;

		let file_path = cache_dir
			.join(format!("{}.json", id));

		data.last_update = Some(Utc::now().to_rfc3339());

		let data_string = serde_json::to_string(&data)
			.map_err(|e| e.to_string())?;

		fs::write(file_path, data_string)
			.map_err(|e| e.to_string())?;

		return Ok(());
	}

	async fn load_cache(source: &Source, id: &str, check_expire: bool) -> Result<Option<ViewContentInfo>, String> {
		let cache_dir = ViewContentInfo::get_cache_dir(source, id).await?
			.join(source.to_string());

		let file_path = cache_dir
			.join(format!("{}.json", id));

		let data = fs::read_to_string(file_path)
			.map_err(|e| e.to_string())?;

		let cache: ViewContentInfo = serde_json::from_str(&data)
			.map_err(|e| e.to_string())?;
		
		if check_expire {
			match &cache.last_update {
				Some(last_update_raw) => {
					let last_update = DateTime::parse_from_rfc3339(last_update_raw)
						.map_err(|e| e.to_string())?
						.with_timezone(&Utc);

					if (Utc::now() - last_update) > Duration::hours(3) {
						return Ok(None);
					}
				}
				_ => {}
			}
			
		}

		return Ok(Some(cache));
	}

	pub async fn update_last_watch(source: &str, id: &str, season_index:u64, episode_index: u64) -> Result<(), String> {
		let source = Source::from_str(source);
		
		match is_in_category(ItemInfo { 
			source: source.to_string(), 
			id: id.to_string() 
		}).await? {
			false => return Ok(()),
			true => {}
		};

		

		let mut data = ViewContentInfo::load_cache(&source, id, false).await?
			.ok_or("Not in favorite. Can't update last watch.")?;

		data.last_watch_season_index = Some(season_index);
		data.last_watch_episode_index = Some(episode_index);

		ViewContentInfo::save_cache(&source, id, &mut data).await?;
		
		return Ok(());
	}

	pub async fn get(source: &str, id: &str, from_cache: bool) -> Result<ViewContentInfo, String> {

		let source = Source::from_str(source);

		if from_cache {
			match ViewContentInfo::load_cache(&source, &id, true).await {
				Ok(Some(cache)) => {
					return Ok(cache);
				},
				_ => {}
			}
		}

		
		let available_cache = match ViewContentInfo::load_cache(&source, &id, false).await {
			Ok(data) => data,
			_ => None
		};

		let source_clone = source.clone();
		let id_clone = id.to_string();

		let data = match tokio::task::spawn_blocking(move || {
			tokio::runtime::Handle::current().block_on(async {
				view_content::new(&source_clone, &id_clone)
					.await
					.unwrap()
			})
		})
		.await
		.map_err(|e| e.to_string()){
			Ok(data) => data,
			Err(e) => {
				// On Error, try to load from cache if available.
				match available_cache {
					Some(cache) => {
						return Ok(cache);
					},
					_ => {
						return Err(e);
					}
				}
				// <-
			}
		};


		let mut result: ViewContentInfo = ViewContentInfo {
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
				.collect(),
			last_watch_season_index: available_cache.as_ref().and_then(|f| f.last_watch_season_index),
			last_watch_episode_index: available_cache.as_ref().and_then(|f| f.last_watch_episode_index),
			last_update: available_cache.as_ref().and_then(|f| f.last_update.to_owned()),
		};


		ViewContentInfo::save_cache(&source, &id,&mut result).await?;
		
		return Ok(result);
	}





}

