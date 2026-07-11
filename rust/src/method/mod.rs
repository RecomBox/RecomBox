// !------------------------------------------------------------
// Most of the functions inside `method` are
// functions to safe wrap and translate types from rust to dart.
//
// The goal is to keep `method` return types as simple as possible before passing it to rust-dart bridge.
// !------------------------------------------------------------
pub mod init;
pub mod torrent_provider;
pub mod metadata_provider;
pub mod plugin_provider;
pub mod download_provider;
pub mod favorite;
pub mod settings;
pub mod check_update;
pub mod watch_state;
pub mod current_watch;
pub mod subtitle_provider;
pub mod clear_cache;

