use iced::futures::channel::mpsc::Sender;
use iced::Subscription;
use notify::{Event, EventKind, RecursiveMode, Watcher};
use std::sync::mpsc;
use std::time::Duration;

use crate::Message;

/// Watches the ctshell config directory (`bar.kdl`, `theme.json`) and emits
/// `Message::ConfigChanged` when its contents change, so edits apply live
/// without restarting the bar. The stream ends (silently) if the directory
/// can't be watched.
pub fn subscription() -> Subscription<Message> {
    Subscription::run(|| {
        iced::stream::channel(16, |output| async move {
            let _ = tokio::task::spawn_blocking(move || watch(output)).await;
        })
    })
}

/// Reloading reads the very files this watches, which inotify reports back
/// as access events on the same directory. Reacting to those would reload
/// forever, so only content changes (not opens/reads) count as relevant.
fn is_content_change(event: &notify::Result<Event>) -> bool {
    matches!(
        event,
        Ok(Event {
            kind: EventKind::Modify(_) | EventKind::Create(_) | EventKind::Remove(_),
            ..
        })
    )
}

fn watch(mut output: Sender<Message>) {
    let dir = crate::paths::config_dir();
    let (tx, rx) = mpsc::channel();

    let Ok(mut watcher) = notify::recommended_watcher(tx) else {
        return;
    };

    if watcher.watch(&dir, RecursiveMode::NonRecursive).is_err() {
        return;
    }

    while let Ok(event) = rx.recv() {
        if !is_content_change(&event) {
            continue;
        }

        // Coalesce the burst of events a single save tends to produce
        // (truncate + write, or a temp-file-then-rename) into one reload.
        while rx.recv_timeout(Duration::from_millis(100)).is_ok() {}

        if output.try_send(Message::ConfigChanged).is_err() {
            break;
        }
    }
}
