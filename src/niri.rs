use iced::futures::channel::mpsc::Sender;
use iced::Subscription;
use niri_ipc::socket::Socket;
use niri_ipc::state::{EventStreamStatePart, WorkspacesState};
use niri_ipc::{Request, Response, Workspace};

use crate::Message;

/// Streams the live niri workspace list, updating on every compositor event
/// rather than polling. The stream ends (silently) if the niri socket is
/// unavailable or closes.
pub fn subscription() -> Subscription<Message> {
    Subscription::run(|| {
        iced::stream::channel(16, |output| async move {
            let _ = tokio::task::spawn_blocking(move || read_workspaces(output)).await;
        })
    })
}

fn read_workspaces(mut output: Sender<Message>) {
    let Ok(mut socket) = Socket::connect() else {
        return;
    };

    if !matches!(socket.send(Request::EventStream), Ok(Ok(Response::Handled))) {
        return;
    }

    let mut state = WorkspacesState::default();
    let mut read_event = socket.read_events();

    while let Ok(event) = read_event() {
        if state.apply(event).is_some() {
            // Ignored by the workspaces state part (e.g. a window event).
            continue;
        }

        let mut workspaces: Vec<Workspace> = state.workspaces.values().cloned().collect();
        workspaces.sort_by(|a, b| a.output.cmp(&b.output).then(a.idx.cmp(&b.idx)));

        if output.try_send(Message::WorkspacesChanged(workspaces)).is_err() {
            break;
        }
    }
}

/// Fire-and-forget: asks niri to switch to the given workspace. Runs on its
/// own OS thread so it never blocks the UI.
pub fn focus_workspace(id: u64) {
    std::thread::spawn(move || {
        if let Ok(mut socket) = Socket::connect() {
            let _ = socket.send(Request::Action(niri_ipc::Action::FocusWorkspace {
                reference: niri_ipc::WorkspaceReferenceArg::Id(id),
            }));
        }
    });
}
