use librqbit::*;

use std::{error::Error, path::PathBuf};

use serde_json::{to_string};


pub async fn new(torrent_file: &PathBuf) -> Result<TorrentMetaV1Info<ByteBufOwned>, Box<dyn Error>>{
    let session = Session::new("tmp/downloads".into())
        .await
        .expect("Failed to create session");

    let mut options = AddTorrentOptions::default();
    options.overwrite = true;
    options.list_only = true;

    
    let add_torrent_res = session
        .add_torrent(
            AddTorrent::from_local_filename(torrent_file.to_str().ok_or("Unable to convert to str")?)?,
            Some(options),
        )
        .await
        .expect("Failed to add torrent");
    

    let list_only_opt = match add_torrent_res {
        AddTorrentResponse::ListOnly(res) => Some(res),
        _ => None
    };

    session.stop().await;

    let torrent_info = list_only_opt
        .ok_or("Unable to extract torrent info")?.info;

    return Ok(torrent_info);

}