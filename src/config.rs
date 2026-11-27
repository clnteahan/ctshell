use iced_layershell::reexport::{Anchor, Layer as ShellLayer};

/// Which screen edge the bar is docked to. Determines both the anchor
/// used for the Wayland layer-shell surface and the bar's orientation.
#[derive(knuffel::DecodeScalar, Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Edge {
    #[default]
    Top,
    Bottom,
    Left,
    Right,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Orientation {
    Horizontal,
    Vertical,
}

impl Edge {
    pub fn orientation(self) -> Orientation {
        match self {
            Edge::Top | Edge::Bottom => Orientation::Horizontal,
            Edge::Left | Edge::Right => Orientation::Vertical,
        }
    }

    pub fn anchor(self) -> Anchor {
        match self {
            Edge::Top => Anchor::Top | Anchor::Left | Anchor::Right,
            Edge::Bottom => Anchor::Bottom | Anchor::Left | Anchor::Right,
            Edge::Left => Anchor::Left | Anchor::Top | Anchor::Bottom,
            Edge::Right => Anchor::Right | Anchor::Top | Anchor::Bottom,
        }
    }

    /// (width, height) for the layer-shell surface, given the bar's
    /// thickness. `0` tells the compositor to stretch that dimension to
    /// fill the anchored edges.
    pub fn size(self, thickness: u32) -> (u32, u32) {
        match self.orientation() {
            Orientation::Horizontal => (0, thickness),
            Orientation::Vertical => (thickness, 0),
        }
    }
}

/// Which layer-shell stacking layer the bar renders on.
#[derive(knuffel::DecodeScalar, Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Layer {
    Background,
    Bottom,
    #[default]
    Top,
    Overlay,
}

impl Layer {
    pub fn to_shell_layer(self) -> ShellLayer {
        match self {
            Layer::Background => ShellLayer::Background,
            Layer::Bottom => ShellLayer::Bottom,
            Layer::Top => ShellLayer::Top,
            Layer::Overlay => ShellLayer::Overlay,
        }
    }
}

#[derive(knuffel::Decode, Debug, Clone, Default)]
pub struct ClockWidget {
    #[knuffel(property)]
    pub format: Option<String>,
    /// Font family for this widget, overriding `BarConfig::font`.
    #[knuffel(property)]
    pub font: Option<String>,
}

/// How individual workspaces are rendered by the `workspaces` widget.
#[derive(knuffel::DecodeScalar, Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum WorkspaceStyle {
    #[default]
    Numbers,
    Dots,
    Names,
}

#[derive(knuffel::Decode, Debug, Clone, Default)]
pub struct WorkspaceWidget {
    #[knuffel(property, default)]
    pub style: WorkspaceStyle,
    #[knuffel(property, default)]
    pub padding: Option<u16>,
    /// Font family for this widget, overriding `BarConfig::font`.
    #[knuffel(property)]
    pub font: Option<String>,
}

/// One entry in a widget section. Each variant corresponds to a KDL node
/// name (kebab-case), e.g. `clock format="%H:%M"`.
#[derive(knuffel::Decode, Debug, Clone)]
pub enum WidgetNode {
    Clock(ClockWidget),
    Workspaces(WorkspaceWidget),
}

#[derive(knuffel::Decode, Debug, Clone, Default)]
pub struct Widgets {
    #[knuffel(child, unwrap(children), default)]
    pub start: Vec<WidgetNode>,
    #[knuffel(child, unwrap(children), default)]
    pub center: Vec<WidgetNode>,
    #[knuffel(child, unwrap(children), default)]
    pub end: Vec<WidgetNode>,
}

#[derive(knuffel::Decode, Debug, Clone)]
pub struct BarConfig {
    #[knuffel(child, unwrap(argument), default)]
    pub edge: Edge,
    #[knuffel(child, unwrap(argument), default)]
    pub layer: Layer,
    /// Name of the output (e.g. "eDP-1") to pin the bar to. If unset, the
    /// bar binds to whichever output is active at start, and the
    /// `workspaces` widget shows workspaces from every output.
    #[knuffel(child, unwrap(argument))]
    pub output: Option<String>,
    #[knuffel(child, unwrap(argument), default = 32)]
    pub thickness: u32,
    #[knuffel(child, unwrap(argument), default = 0)]
    pub margin: i32,
    #[knuffel(child, unwrap(argument), default = 1.0)]
    pub scale: f32,
    #[knuffel(child, unwrap(argument), default = true)]
    pub exclusive: bool,
    /// Default font family for all widgets. Individual widgets can override
    /// this with their own `font` property.
    #[knuffel(child, unwrap(argument))]
    pub font: Option<String>,
    #[knuffel(child, default)]
    pub widgets: Widgets,
}

impl Default for BarConfig {
    fn default() -> Self {
        BarConfig {
            edge: Edge::Top,
            layer: Layer::Top,
            output: None,
            thickness: 32,
            margin: 0,
            scale: 1.0,
            exclusive: true,
            font: None,
            widgets: Widgets {
                start: Vec::new(),
                center: vec![WidgetNode::Clock(ClockWidget {
                    format: None,
                    font: None,
                })],
                end: Vec::new(),
            },
        }
    }
}

impl BarConfig {
    pub fn load() -> Self {
        let path = crate::paths::config_dir().join("bar.kdl");
        let text = match std::fs::read_to_string(&path) {
            Ok(text) => text,
            Err(_) => return BarConfig::default(),
        };

        match knuffel::parse::<BarConfig>(&path.to_string_lossy(), &text) {
            Ok(config) => config,
            Err(err) => {
                eprintln!("ctshell: failed to parse {}: {err}", path.display());
                BarConfig::default()
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_full_config() {
        let kdl = r#"
            edge "left"
            layer "overlay"
            output "eDP-1"
            thickness 40
            margin 4
            scale 1.5
            exclusive false
            font "JetBrainsMono Nerd Font"

            widgets {
                start {
                    clock format="%H:%M" font="Iosevka"
                }
                center {
                }
                end {
                    clock
                    workspaces style="dots"
                }
            }
        "#;

        let config: BarConfig = knuffel::parse("test.kdl", kdl).unwrap();

        assert_eq!(config.edge, Edge::Left);
        assert_eq!(config.layer, Layer::Overlay);
        assert_eq!(config.output.as_deref(), Some("eDP-1"));
        assert_eq!(config.thickness, 40);
        assert_eq!(config.margin, 4);
        assert_eq!(config.scale, 1.5);
        assert!(!config.exclusive);
        assert_eq!(config.font.as_deref(), Some("JetBrainsMono Nerd Font"));
        assert_eq!(config.edge.orientation(), Orientation::Vertical);
        assert_eq!(config.widgets.start.len(), 1);
        assert_eq!(config.widgets.center.len(), 0);
        assert_eq!(config.widgets.end.len(), 2);

        match &config.widgets.start[0] {
            WidgetNode::Clock(clock) => {
                assert_eq!(clock.format.as_deref(), Some("%H:%M"));
                assert_eq!(clock.font.as_deref(), Some("Iosevka"));
            }
            WidgetNode::Workspaces(_) => panic!("expected clock"),
        }

        match &config.widgets.end[1] {
            WidgetNode::Workspaces(workspaces) => {
                assert_eq!(workspaces.style, WorkspaceStyle::Dots);
                assert_eq!(workspaces.font, None);
            }
            WidgetNode::Clock(_) => panic!("expected workspaces"),
        }
    }

    #[test]
    fn empty_config_uses_defaults() {
        let config: BarConfig = knuffel::parse("test.kdl", "").unwrap();
        assert_eq!(config.edge, Edge::Top);
        assert_eq!(config.thickness, 32);
        assert!(config.output.is_none());
        assert!(config.font.is_none());
        assert!(config.widgets.start.is_empty());
    }
}
