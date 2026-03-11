use librqbit::*;

use std::{error::Error, path::PathBuf};

use serde_json::{to_string};

use super::torrent_session::TorrentSession;


pub async fn new(torrent_file: &PathBuf) -> Result<TorrentMetaV1Info<ByteBufOwned>, Box<dyn Error>>{
    let session = TorrentSession::get()?;

    let mut options = AddTorrentOptions::default();
    options.overwrite = true;
    options.list_only = true;

    
    let add_torrent_res = session
        .add_torrent(
            AddTorrent::from_local_filename(torrent_file.to_str().ok_or("Unable to convert to str")?)?,
            Some(options),
        )
        .await?;
    

    let list_only_opt = match add_torrent_res {
        AddTorrentResponse::ListOnly(res) => Some(res),
        _ => None
    };

    let torrent_info = list_only_opt
        .ok_or("Unable to extract torrent info")?.info;

    return Ok(torrent_info);

}