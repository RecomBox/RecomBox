use librqbit::ManagedTorrent;
use std::{path::PathBuf, sync::{Arc, LazyLock}};

use dashmap::DashMap;


pub static TORRENT_HANDLE: LazyLock<DashMap<PathBuf,DashMap<usize, Arc<ManagedTorrent>>>> = LazyLock::new(DashMap::new);
