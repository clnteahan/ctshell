import QtQuick
import qs

// Niri.qml lives alongside this file in Modules/, so it's visible here
// without an explicit import.
Row {
  id: root

  // The ShellScreen this indicator belongs to (from PanelWindow.screen),
  // used to show only the workspaces that live on this monitor.
  required property var screen

  spacing: 6

  readonly property var _workspaces: {
    if (!root.screen)
      return []
    return Niri.workspaces
      .filter(w => w.output === root.screen.name)
      .sort((a, b) => a.idx - b.idx)
  }

  Repeater {
    model: root._workspaces

    Rectangle {
      id: pill
      required property var modelData

      readonly property bool active: modelData.is_active
      readonly property bool occupied: modelData.active_window_id !== null
      readonly property bool urgent: modelData.is_urgent

      anchors.verticalCenter: parent.verticalCenter
      width: active ? 26 : 16
      height: 16
      radius: height / 2

      color: {
        if (urgent) return Theme.colors.error
        if (active) return Theme.colors.primary
        return Theme.colors.on_primary
      }
      border.width: (active || urgent) ? 0 : (occupied ? 1.5 : 1)
      border.color: occupied ? Theme.colors.on_surface_variant : Theme.colors.outline

      Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 350 } }

      Text {
        anchors.centerIn: parent
        visible: pill.active
        text: pill.modelData.idx
        font.pixelSize: 10
        font.bold: true
        color: pill.urgent ? Theme.colors.on_error : Theme.colors.on_primary
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Niri.focus(pill.modelData.id)
      }
    }
  }
}
