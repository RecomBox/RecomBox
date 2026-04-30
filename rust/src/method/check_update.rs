
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use reqwest::Client;
use serde_json::{Value};
use std::env::consts::{OS, ARCH};
use semver::Version;

use crate::utils::settings::Settings;

#[frb(json_serializable)]
#[derive(Debug, Deserialize, Serialize, PartialEq, Eq, Clone)]
pub struct CheckUpdate{
    pub latest_version: String,
    pub download_url: String
}

impl CheckUpdate {
    pub async fn new() -> anyhow::Result<Option<CheckUpdate>>{
        let url = "https://github.com/RecomBox/RecomBox/releases/latest/download/latest.json";
        let client = Client::new();

        let res = client.get(url).send().await?;
        let data: Value = res.json().await?;

        println!("{:?}", data);

        let raw_latest_version = data.get("version")
            .ok_or(anyhow::Error::msg(format!("[{}:{}] unable to find version", file!(), line!())))?
            .as_str()
            .ok_or(anyhow::Error::msg(format!("[{}:{}] unable to find version", file!(), line!())))?;

        let download_url = match data.get("release").and_then(|f| f.get(OS)).and_then(|f| f.get(ARCH)) {
            Some(url) => url.to_string(),
            None => {
                if OS == "android" {
                    match data.get("release").and_then(|f| f.get(OS)).and_then(|f| f.get("universal")) {
                        Some(url) => url.to_string(),
                        None => return Err(anyhow::Error::msg(format!("[{}:{}] unable to find download url", file!(), line!())))
                    }
                }else{
                    return Err(anyhow::Error::msg(format!("[{}:{}] unable to find download url", file!(), line!())))
                }

            }
        };
        
        let current_version = Version::parse(&Settings::get()?.version)?;


        let latest_version = Version::parse(raw_latest_version)?;
        if latest_version > current_version {
            return Ok(Some(CheckUpdate{
                latest_version: raw_latest_version.to_string(),
                download_url
            }));
        }

        return Ok(None);
    }
    
}

