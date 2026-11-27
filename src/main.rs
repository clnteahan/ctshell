mod config;
mod niri;
mod paths;
mod theme;
mod watch;
mod widgets;

use chrono::Local;
use iced::widget::{column, container, row};
use iced::{Center, Element, Fill, Subscription, Task};
use iced_layershell::reexport::KeyboardInteractivity;
use iced_layershell::settings::{LayerShellSettings, Settings, StartMode};
use iced_layershell::to_layer_message;

use config::{BarConfig, Orientation, WidgetNode};
use niri_ipc::Workspace;
use theme::Palette;
use std::thread;

struct App {
    config: BarConfig,
    palette: Palette,
    workspaces: Vec<Workspace>,
}

impl Default for App {
    fn default() -> Self {
        let config_handle = thread::spawn(BarConfig::load);
        let palette_handle = thread::spawn(Palette::load);

        App {
            config: config_handle.join().expect("config thread panicked"),
            palette: palette_handle.join().expect("palette thread panicked"),
            workspaces: Vec::new(),
        }
    }
}

#[to_layer_message]
#[derive(Debug, Clone)]
enum Message {
    Tick,
    WorkspacesChanged(Vec<Workspace>),
    FocusWorkspace(u64),
    ConfigChanged,
}

fn namespace() -> String {
    String::from("ctshell-bar")
}

fn update(state: &mut App, message: Message) -> Task<Message> {
    match message {
        Message::Tick => Task::none(),
        Message::WorkspacesChanged(workspaces) => {
            state.workspaces = workspaces;
            Task::none()
        }
        Message::FocusWorkspace(id) => {
            niri::focus_workspace(id);
            Task::none()
        }
        Message::ConfigChanged => {
            // Picks up widget/theme changes live. Bar geometry (edge, layer,
            // thickness, margin, exclusive, output) is baked into the
            // layer-shell surface at startup and needs a restart to change.
            state.config = BarConfig::load();
            state.palette = Palette::load();
            eprintln!("ctshell: reloaded config");
            Task::none()
        }
        _ => Task::none(),
    }
}

fn subscription(_state: &App) -> Subscription<Message> {
    Subscription::batch([
        iced::time::every(std::time::Duration::from_secs(1)).map(|_| Message::Tick),
        niri::subscription(),
        watch::subscription(),
    ])
}

fn style(state: &App, _theme: &iced::Theme) -> iced::theme::Style {
    iced::theme::Style {
        background_color: state.palette.background,
        text_color: state.palette.on_background,
    }
}

fn section<'a>(
    widgets: &'a [WidgetNode],
    orientation: Orientation,
    context: &widgets::Context<'a>,
) -> Element<'a, Message> {
    let elements = widgets.iter().map(|widget| widgets::view(widget, context));

    match orientation {
        Orientation::Horizontal => row(elements).spacing(8).align_y(Center).into(),
        Orientation::Vertical => column(elements).spacing(8).align_x(Center).into(),
    }
}

fn view(state: &App) -> Element<'_, Message> {
    let orientation = state.config.edge.orientation();
    let context = widgets::Context {
        now: Local::now(),
        workspaces: &state.workspaces,
        output: state.config.output.as_deref(),
        palette: &state.palette,
        font: state.config.font.as_deref(),
    };
    let start = section(&state.config.widgets.start, orientation, &context);
    let center = section(&state.config.widgets.center, orientation, &context);
    let end = section(&state.config.widgets.end, orientation, &context);

    match orientation {
        Orientation::Horizontal => row![
            container(start).width(Fill).align_x(iced::Left),
            container(center).width(Fill).align_x(Center),
            container(end).width(Fill).align_x(iced::Right),
        ]
        .height(Fill)
        .align_y(Center)
        .into(),
        Orientation::Vertical => column![
            container(start).height(Fill).align_y(iced::Top),
            container(center).height(Fill).align_y(Center),
            container(end).height(Fill).align_y(iced::Bottom),
        ]
        .width(Fill)
        .align_x(Center)
        .into(),
    }
}

fn layer_shell_settings(config: &BarConfig) -> Settings {
    let (width, height) = config.edge.size(config.thickness);
    let exclusive_zone = if config.exclusive {
        config.thickness as i32
    } else {
        -1
    };

    let start_mode = match &config.output {
        Some(output) => StartMode::TargetScreen(output.clone()),
        None => StartMode::default(),
    };

    Settings {
        layer_settings: LayerShellSettings {
            anchor: config.edge.anchor(),
            layer: config.layer.to_shell_layer(),
            exclusive_zone,
            size: Some((width, height)),
            margin: (config.margin, config.margin, config.margin, config.margin),
            keyboard_interactivity: KeyboardInteractivity::None,
            start_mode,
            ..Default::default()
        },
        ..Default::default()
    }
}

fn main() -> Result<(), iced_layershell::Error> {
    let App {
        config, palette, ..
    } = App::default();
    let settings = layer_shell_settings(&config);

    iced_layershell::application(
        move || App {
            config: config.clone(),
            palette,
            workspaces: Vec::new(),
        },
        namespace,
        update,
        view,
    )
    .subscription(subscription)
    .style(style)
    .scale_factor(|state: &App| state.config.scale)
    .settings(settings)
    .run()
}
