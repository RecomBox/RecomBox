// ------------------------------------------------------------
// Most of the functions inside `method` are
// functions to safe wrap and translate types from rust ot dart.
//
// The goal is to keep `method` return types as simple as possible before passing it to dart types bridge.
// ------------------------------------------------------------
pub mod init;
pub mod get_torrent_info;
pub mod spawn_stream_server;
pub mod generate_torrent_handle;
pub mod metadata_provider;
pub mod settings;

