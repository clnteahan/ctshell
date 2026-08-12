pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Quickshell has no first-party niri module (unlike Hyprland/Sway), so this
// singleton talks to niri directly over its IPC (`niri msg`). It keeps a flat
// list of every workspace on every output, kept live via `event-stream`, and
// lets widgets switch workspaces via focus(id).
Singleton {
  id: root

  // Each entry: { id, idx, name, output, is_urgent, is_active, is_focused, active_window_id }
  // Reassigned wholesale (never mutated in place) so bindings react correctly.
  property var workspaces: []

  function focus(id) {
    focusProc.command = ["niri", "msg", "action", "focus-workspace", String(id)]
    focusProc.running = true
  }

  function _patch(id, changes) {
    root.workspaces = root.workspaces.map(w => w.id === id ? Object.assign({}, w, changes) : w)
  }

  Process {
    id: focusProc
  }

  Process {
    id: eventStream
    command: ["niri", "msg", "-j", "event-stream"]
    running: true

    // niri might not be up yet when quickshell starts, or could restart;
    // keep retrying so workspaces recover on their own.
    onRunningChanged: if (!running) running = true

    stdout: SplitParser {
      onRead: data => {
        if (!data)
          return

        let event
        try {
          event = JSON.parse(data)
        } catch (e) {
          return
        }

        if (event.WorkspacesChanged) {
          root.workspaces = event.WorkspacesChanged.workspaces
        } else if (event.WorkspaceActivated) {
          const id = event.WorkspaceActivated.id
          const focused = event.WorkspaceActivated.focused
          const target = root.workspaces.find(w => w.id === id)
          if (!target)
            return

          // A workspace becoming "active" only makes it the visible workspace
          // on its own output; other outputs are untouched. "focused" is
          // global - at most one workspace is focused across all outputs.
          root.workspaces = root.workspaces.map(w => {
            if (w.id === id)
              return Object.assign({}, w, { is_active: true, is_focused: focused })
            if (w.output === target.output)
              return Object.assign({}, w, { is_active: false })
            if (focused && w.is_focused)
              return Object.assign({}, w, { is_focused: false })
            return w
          })
        } else if (event.WorkspaceUrgencyChanged) {
          root._patch(event.WorkspaceUrgencyChanged.id, { is_urgent: event.WorkspaceUrgencyChanged.urgent })
        } else if (event.WorkspaceActiveWindowChanged) {
          root._patch(event.WorkspaceActiveWindowChanged.workspace_id, { active_window_id: event.WorkspaceActiveWindowChanged.active_window_id })
        }
      }
    }
  }
}
