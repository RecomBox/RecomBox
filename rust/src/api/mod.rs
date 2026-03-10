// ------------------------------------------------------------
// Most of the functions inside `api` are
// functions to safe wrap and translate types from `utils` functions.
//
// The goal is to keep `api` return types as simple as possible before passing it to flutter dart type.
// ------------------------------------------------------------

pub mod get_torrent_info;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
