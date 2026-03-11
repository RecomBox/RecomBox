use crate::utils::torrent_session::TorrentSession;

pub async fn init_torrent_session() -> Result<(), String> {
    TorrentSession::init().await
    .map_err(|e| e.to_string())?;
    return Ok(());
}
