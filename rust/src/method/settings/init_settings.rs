use crate::utils::settings::Settings;

pub fn init_settings(settings: Settings) -> anyhow::Result<()> {
    return Settings::init(settings);
    
}