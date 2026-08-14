
use recombox_metadata_provider::{
	view_content,
};
use recombox_metadata_provider::global_types::Source;


use serde::{Deserialize, Serialize};
use chrono::{Utc, DateTime, Duration};
use std::path::PathBuf;
use std::fs;


use crate::method::favorite::{is_in_category::is_in_category};
use crate::utils::download_file;
use crate::utils::settings::Settings;

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct ExternalID {
    pub mal: Option<String>,
    pub kitsu: Option<String>,
    pub imdb: Option<String>
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ViewContentInfo {
	pub source: String,
	pub external_id: ExternalID,
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
	pub episodes: Vec<u64>, // Seasons -> Episodes
	pub last_watch_season_index: Option<u64>,
	pub last_watch_episode_index: Option<u64>,
	pub last_update: Option<String>,
}


impl ViewContentInfo{
	async fn get_cache_dir(source: &Source, id: &str) -> Result<PathBuf, String> {
		let settings = Settings::get()
			.map_err(|e| e.to_string())?;

		let is_in_fav = is_in_category(&source.to_string(), id).await?;

		if is_in_fav {
			let cache_dir = PathBuf::from(settings.paths.app_support_dir.clone())
				.join("favorite")
				.join(source.to_string())
				.join(id.to_string());
			return Ok(cache_dir);
		}else{
			
			let app_cache_dir = PathBuf::from(settings.paths.app_cache_dir.clone())
				.join("view_content_info")
				.join(source.to_string())
				.join(id.to_string());
			return Ok(app_cache_dir);

		}

	}

	async fn save_cache(source: &Source, id: &str, data: &mut ViewContentInfo, cache_media: bool) -> Result<(), String> {

		

		let cache_dir = ViewContentInfo::get_cache_dir(source, id).await?;

		fs::create_dir_all(&cache_dir)
			.map_err(|e| e.to_string())?;

		// -> Cache Media If in favorite
		if cache_media {
			let is_in_favorite = is_in_category(&source.to_string(), id).await?;
			
			if is_in_favorite {
				let thumbnail_path = cache_dir
					.join("thumbnail.png");
				download_file::new(&data.thumbnail_url, Some(&thumbnail_path)).await.ok();
				
				let banner_path = cache_dir
					.join("banner.png");
				download_file::new(&data.banner_url, Some(&banner_path)).await.ok();
			}
		}
		// <-

		let file_path = cache_dir
			.join("data.json");

		data.last_update = Some(Utc::now().to_rfc3339());

		let data_string = serde_json::to_string(&data)
			.map_err(|e| e.to_string())?;

		fs::write(file_path, data_string)
			.map_err(|e| e.to_string())?;

		return Ok(());
	}

	async fn load_cache(source: &Source, id: &str, check_expire: bool) -> Result<Option<ViewContentInfo>, String> {
		let cache_dir = ViewContentInfo::get_cache_dir(source, id).await?;

		
		let file_path = cache_dir
			.join("data.json");

		let raw_data = fs::read_to_string(file_path)
			.map_err(|e| e.to_string())?;

		let mut data: ViewContentInfo = serde_json::from_str(&raw_data)
			.map_err(|e| e.to_string())?;

		// -> Replace Media If in favorite
		let is_in_favorite = is_in_category(&source.to_string(), id).await?;
		
		if is_in_favorite {
			let thumbnail_path = cache_dir
				.join("thumbnail.png");

			if thumbnail_path.exists(){
				data.thumbnail_url = thumbnail_path.to_string_lossy().to_string();
			}
			
			let banner_path = cache_dir
				.join("banner.png");

			if banner_path.exists(){
				data.banner_url = banner_path.to_string_lossy().to_string();
			}
			
		}
		// <-
		
		if check_expire {
			match &data.last_update {
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

		return Ok(Some(data));
	}

	pub async fn update_last_watch(source: &str, id: &str, season_index:u64, episode_index: u64) -> Result<(), String> {

		let source = Source::from_str(source);
		
		
		let mut data = ViewContentInfo::load_cache(&source, id, false).await?
			.ok_or("Not in favorite. Can't update last watch.")?;

		data.last_watch_season_index = Some(season_index);
		data.last_watch_episode_index = Some(episode_index);

		ViewContentInfo::save_cache(&source, id, &mut data, false).await?;
		
		return Ok(());
	}

	pub async fn get(source: &str, id: &str, from_cache: bool, check_expire: bool) -> Result<ViewContentInfo, String> {

		let source = Source::from_str(source);

		if from_cache {
			match ViewContentInfo::load_cache(&source, &id, check_expire).await {
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


	let settings = Settings::get()
	.map_err(|e| e.to_string())?;

	let params = view_content::ViewContentParams{
		tmdb_token: settings.tmdb_rat_token.clone()
			.ok_or(String::from("Missing tmdb_rat_token"))?,
		source: source.clone(),
		id: id.to_string()
	};

		let data = view_content::new(&params)
			.await
			.map_err(|e| e.to_string())?;

		let external_id = ExternalID{
			imdb: data.external_id.imdb,
			kitsu: data.external_id.kitsu,
			mal: data.external_id.mal
		};


		let mut result: ViewContentInfo = ViewContentInfo {
			source: source.to_string(),
			external_id,
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
			episodes: data.episodes,
			last_watch_season_index: available_cache.as_ref().and_then(|f| f.last_watch_season_index),
			last_watch_episode_index: available_cache.as_ref().and_then(|f| f.last_watch_episode_index),
			last_update: available_cache.as_ref().and_then(|f| f.last_update.to_owned()),
		};

		ViewContentInfo::save_cache(&source, &id,&mut result, true).await?;
		
		return Ok(result);
	}





}

