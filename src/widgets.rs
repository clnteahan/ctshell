use chrono::{DateTime, Local};
use iced::widget::{button, row, text};
use iced::{Element, Font};
use niri_ipc::Workspace;

use std::collections::HashMap;
use std::sync::Mutex;
use std::sync::OnceLock;

use crate::config::{ClockWidget, WidgetNode, WorkspaceStyle, WorkspaceWidget};
use crate::theme::Palette;
use crate::Message;

const DEFAULT_CLOCK_FORMAT: &str = "%Y-%m-%d %H:%M:%S";
const DEFAULT_PADDING: u16 = 2;

/// Shared, read-only state widgets may need while rendering. Threaded
/// through from `App` so individual widgets stay stateless.
pub struct Context<'a> {
    pub now: DateTime<Local>,
    pub workspaces: &'a [Workspace],
    /// Output name the bar is pinned to (`BarConfig::output`). When `None`,
    /// the workspace widget shows workspaces from every output.
    pub output: Option<&'a str>,
    pub palette: &'a Palette,
    /// Default font family (`BarConfig::font`), used when a widget doesn't
    /// set its own `font` property.
    pub font: Option<&'a str>,
}

/// `iced::Font` needs a `&'static str` family name, but family names come
/// from parsed config strings. Leaking is cheap and bounded here: each
/// distinct name is leaked at most once, cached by value, no matter how
/// many times the config reloads or the bar re-renders.
fn font_cache() -> &'static Mutex<HashMap<String, &'static str>> {
    static CACHE: OnceLock<Mutex<HashMap<String, &'static str>>> = OnceLock::new();
    CACHE.get_or_init(|| Mutex::new(HashMap::new()))
}

fn resolve_font(name: Option<&str>) -> Option<Font> {
    let name = name?;
    let mut cache = font_cache().lock().unwrap();
    let leaked = *cache
        .entry(name.to_owned())
        .or_insert_with(|| Box::leak(name.to_owned().into_boxed_str()));
    Some(Font::with_name(leaked))
}

pub fn view<'a>(widget: &'a WidgetNode, context: &Context<'a>) -> Element<'a, Message> {
    match widget {
        WidgetNode::Clock(clock) => clock_view(clock, context),
        WidgetNode::Workspaces(workspace_widget) => workspaces_view(workspace_widget, context),
    }
}

fn clock_view<'a>(widget: &ClockWidget, context: &Context<'a>) -> Element<'a, Message> {
    let format = widget.format.as_deref().unwrap_or(DEFAULT_CLOCK_FORMAT);
    let mut label = text(context.now.format(format).to_string());

    if let Some(font) = resolve_font(widget.font.as_deref().or(context.font)) {
        label = label.font(font);
    }

    label.into()
}

fn workspaces_view<'a>(widget: &WorkspaceWidget, context: &Context<'a>) -> Element<'a, Message> {
    let palette = *context.palette;
    let font = resolve_font(widget.font.as_deref().or(context.font));

    let buttons = context
        .workspaces
        .iter()
        .filter(|ws| match context.output {
            Some(output) => ws.output.as_deref() == Some(output),
            None => true,
        })
        .map(move |ws| {
            let label = match widget.style {
                WorkspaceStyle::Numbers => ws.idx.to_string(),
                WorkspaceStyle::Dots => (if ws.is_active { "\u{25cf}" } else { "\u{25cb}" }).to_string(),
                WorkspaceStyle::Names => ws.name.clone().unwrap_or_else(|| ws.idx.to_string()),
            };
            let text_color = if ws.is_active {
                palette.primary
            } else {
                palette.on_background
            };
            let padding = widget.padding.unwrap_or(DEFAULT_PADDING);

            let mut label = text(label).color(text_color);
            if let Some(font) = font {
                label = label.font(font);
            }

            button(label)
                .on_press(Message::FocusWorkspace(ws.id))
                .padding(padding)
                .style(move |_theme, _status| button::Style {
                    background: None,
                    text_color,
                    ..button::Style::default()
                })
                .into()
        });

    row(buttons).spacing(4).into()
}
