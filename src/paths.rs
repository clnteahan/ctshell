use std::path::PathBuf;

/// `$XDG_CONFIG_HOME/ctshell`, falling back to `~/.config/ctshell`.
pub fn config_dir() -> PathBuf {
    let base = std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(std::env::var("HOME").unwrap_or_default()).join(".config"));
    base.join("ctshell")
}
