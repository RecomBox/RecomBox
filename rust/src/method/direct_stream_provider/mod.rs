use serde::{Deserialize, Serialize};
use chrono::{Utc, DateTime, Duration};
use std::path::PathBuf;
use std::fs;
use std::collections::HashMap;

use crate::utils::settings::Settings;

const DATA_URL: &str = "https://raw.githubusercontent.com/RecomBox/recombox_direct_stream_provider/refs/heads/main/data.json";
const CACHE_DURATION: Duration = Duration::hours(5);

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DirectStreamProvider {
  pub icon: String,
  pub title: String,
  pub id_type: IdType,
  pub url_schema: UrlSchema,
  pub allowed_navigation_origin: Vec<String>
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IdType {
  pub movies: Option<String>,
  pub tv: Option<String>,
  pub anime: Option<String>,
}

impl IdType{
  pub fn get(&self, s: &str) -> Option<String> {
    match s {
      "movies" => self.movies.clone(),
      "tv" => self.tv.clone(),
      "anime" => self.anime.clone(),
      _ => None
    }
  }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UrlSchema {
  pub movies: Option<String>,
  pub tv: Option<String>,
  pub anime: Option<String>,
}

impl UrlSchema{
  pub fn get(&self, s: &str) -> Option<String> {
    match s {
      "movies" => self.movies.clone(),
      "tv" => self.tv.clone(),
      "anime" => self.anime.clone(),
      _ => None
    }
  }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct DirectStreamCache {
  last_update: String,
  data: HashMap<String, DirectStreamProvider>,
}


impl DirectStreamProvider{

  fn get_cache_path() -> Result<PathBuf, String> {
    let settings = Settings::get()
      .map_err(|e| e.to_string())?;

    return Ok(
      PathBuf::from(settings.paths.app_support_dir.clone())
        .join("direct_stream_cache.json")
    );
  }

  async fn fetch_remote() -> Result<HashMap<String, DirectStreamProvider>, String> {
    let response = reqwest::get(DATA_URL)
      .await
      .map_err(|e| e.to_string())?;

    let data: HashMap<String, DirectStreamProvider> = response
      .json()
      .await
      .map_err(|e| e.to_string())?;

    return Ok(data);
  }

  fn load_cache(check_expire: bool) -> Result<Option<HashMap<String, DirectStreamProvider>>, String> {
    let cache_path = DirectStreamProvider::get_cache_path()?;

    if !cache_path.exists() {
      return Ok(None);
    }

    let raw_data = fs::read_to_string(&cache_path)
      .map_err(|e| e.to_string())?;

    let cache: DirectStreamCache = serde_json::from_str(&raw_data)
      .map_err(|e| e.to_string())?;

    if check_expire {
      let last_update = DateTime::parse_from_rfc3339(&cache.last_update)
        .map_err(|e| e.to_string())?
        .with_timezone(&Utc);

      if (Utc::now() - last_update) > CACHE_DURATION {
        return Ok(None);
      }
    }

    return Ok(Some(cache.data));
  }

  fn save_cache(data: &HashMap<String, DirectStreamProvider>) -> Result<(), String> {
    let cache_path = DirectStreamProvider::get_cache_path()?;

    if let Some(parent) = cache_path.parent() {
      fs::create_dir_all(parent)
        .map_err(|e| e.to_string())?;
    }

    let cache = DirectStreamCache {
      last_update: Utc::now().to_rfc3339(),
      data: data.clone(),
    };

    let data_string = serde_json::to_string(&cache)
      .map_err(|e| e.to_string())?;

    fs::write(cache_path, data_string)
      .map_err(|e| e.to_string())?;

    return Ok(());
  }

  pub async fn get_all(from_cache: bool) -> Result<HashMap<String, DirectStreamProvider>, String> {

    if from_cache {
      // -> Try cache first (valid + under 3h). Any error/corruption/missing falls through to a fresh fetch.
      match DirectStreamProvider::load_cache(true) {
        Ok(Some(cache)) => {
          return Ok(cache);
        },
        _ => {}
      }
      // <-
    }
    

    let data = DirectStreamProvider::fetch_remote().await?;

    // Cache write failure shouldn't block returning fresh data
    DirectStreamProvider::save_cache(&data).ok();

    return Ok(data);
  }

  pub async fn get(id: &str) -> Result<DirectStreamProvider, String> {

    let data = DirectStreamProvider::get_all(true).await?;

    return data.get(id)
      .cloned()
      .ok_or(format!("Direct stream provider '{}' not found", id));
  }
}