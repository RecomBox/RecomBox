use walkdir::WalkDir;

pub fn new(path: &str) -> u64 {
  WalkDir::new(path)
    .into_iter()
    .filter_map(|entry| entry.ok())
    .filter_map(|entry| entry.metadata().ok())
    .filter(|metadata| metadata.is_file())
    .fold(0, |acc, m| acc + m.len())
}