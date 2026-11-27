use iced::Color;
use serde::Deserialize;

#[derive(Deserialize, Debug, Clone)]
struct RawColor {
    color: String,
}

impl RawColor {
    fn to_color(&self) -> Color {
        let hex = self.color.trim_start_matches('#');
        let [r, g, b] = [0, 2, 4].map(|i| {
            hex.get(i..i + 2)
                .and_then(|byte| u8::from_str_radix(byte, 16).ok())
                .unwrap_or(0)
        });
        Color::from_rgb8(r, g, b)
    }
}

// `dark`/`light` aren't consumed yet: only `default` (matugen's own
// resolved-for-current-wallpaper value) is used today. They're parsed now so
// a manual light/dark override can be wired up later without touching the
// schema again.
#[derive(Deserialize, Debug, Clone)]
#[allow(dead_code)]
struct ColorVariants {
    dark: RawColor,
    default: RawColor,
    light: RawColor,
}

/// Declares the matugen Material Design 3 color roles found in `theme.json`,
/// generating a `Colors` struct (as parsed from JSON) and a resolved
/// `Palette` struct (one `iced::Color` per role) in lockstep, so adding a
/// role only means adding it to this one list.
macro_rules! color_roles {
    ($($role:ident),* $(,)?) => {
        #[derive(Deserialize, Debug, Clone)]
        struct Colors {
            $($role: ColorVariants,)*
        }

        /// A fully resolved set of colors for the active mode. Only a
        /// couple of roles are wired into rendering so far (see `style` in
        /// main.rs); the rest exist for widgets to adopt as they're built.
        #[derive(Debug, Clone, Copy, Default)]
        #[allow(dead_code)]
        pub struct Palette {
            $(pub $role: Color,)*
        }

        impl Colors {
            fn resolve_default(&self) -> Palette {
                Palette {
                    $($role: self.$role.default.to_color(),)*
                }
            }
        }
    };
}

color_roles!(
    background,
    error,
    error_container,
    inverse_on_surface,
    inverse_primary,
    inverse_surface,
    on_background,
    on_error,
    on_error_container,
    on_primary,
    on_primary_container,
    on_primary_fixed,
    on_primary_fixed_variant,
    on_secondary,
    on_secondary_container,
    on_secondary_fixed,
    on_secondary_fixed_variant,
    on_surface,
    on_surface_variant,
    on_tertiary,
    on_tertiary_container,
    on_tertiary_fixed,
    on_tertiary_fixed_variant,
    outline,
    outline_variant,
    primary,
    primary_container,
    primary_fixed,
    primary_fixed_dim,
    scrim,
    secondary,
    secondary_container,
    secondary_fixed,
    secondary_fixed_dim,
    shadow,
    source_color,
    surface,
    surface_bright,
    surface_container,
    surface_container_high,
    surface_container_highest,
    surface_container_low,
    surface_container_lowest,
    surface_dim,
    surface_tint,
    surface_variant,
    tertiary,
    tertiary_container,
    tertiary_fixed,
    tertiary_fixed_dim,
);

#[derive(Deserialize, Debug, Clone)]
struct ThemeFile {
    colors: Colors,
}

impl Palette {
    /// A plain dark fallback, used when `theme.json` is missing or invalid.
    /// Only `background`/`on_background` are set to something visible;
    /// the rest default to transparent until widgets start consuming them.
    fn fallback() -> Self {
        Palette {
            background: Color::from_rgb8(0x10, 0x14, 0x17),
            on_background: Color::from_rgb8(0xe0, 0xe3, 0xe8),
            ..Palette::default()
        }
    }

    pub fn load() -> Self {
        let path = crate::paths::config_dir().join("theme.json");
        let text = match std::fs::read_to_string(&path) {
            Ok(text) => text,
            Err(_) => return Palette::fallback(),
        };

        match serde_json::from_str::<ThemeFile>(&text) {
            Ok(theme) => theme.colors.resolve_default(),
            Err(err) => {
                eprintln!("ctshell: failed to parse {}: {err}", path.display());
                Palette::fallback()
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_matugen_theme() {
        // The real file shipped in the repo root, produced by matugen.
        let json = include_str!("../theme.json");

        let theme: ThemeFile = serde_json::from_str(json).unwrap();
        let palette = theme.colors.resolve_default();

        assert_eq!(palette.background, Color::from_rgb8(0x10, 0x14, 0x17));
        assert_eq!(palette.on_background, Color::from_rgb8(0xe0, 0xe3, 0xe8));
        assert_eq!(palette.primary, Color::from_rgb8(0x96, 0xcc, 0xf8));
    }

    #[test]
    fn falls_back_when_absent() {
        let palette = Palette::fallback();
        assert_eq!(palette.background, Color::from_rgb8(0x10, 0x14, 0x17));
        assert_eq!(palette.on_background, Color::from_rgb8(0xe0, 0xe3, 0xe8));
    }
}
