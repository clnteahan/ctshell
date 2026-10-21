import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.Modules

// Overlay window that stacks active notifications in a screen corner.
// Create it through a LazyLoader (see Notifications.qml).
PanelWindow {
    id: root

    // 0 = top-right, 1 = top-left, 2 = bottom-right, 3 = bottom-left
    readonly property int pos: NotificationManager.position
    property bool showHistoric: false

    visible: NotificationManager.hasNotifications

    anchors {
        top: pos === 0 || pos === 1
        bottom: pos === 2 || pos === 3
        right: pos === 0 || pos === 2
        left: pos === 1 || pos === 3
    }
    margins {
        top: 35      // below the bar
        bottom: 20
        left: 20
        right: 0
    }

    implicitWidth: Math.min(360, (screen ? screen.width : 360) * 0.8)
    implicitHeight: contentColumn.implicitHeight + 20

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore   // don't reserve screen space
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None   // never steal focus

    // Only the cards receive input; the rest of the window is click-through
    mask: Region { item: contentColumn }

    Column {
        id: contentColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        spacing: 8

        Repeater {
          model: showHistoric ? [...NotificationManager.history, ...NotificationManager.activeNotifications] :  NotificationManager.activeNotifications

            delegate: NotificationItem {
                required property var modelData
                notification: modelData
                width: contentColumn.width
            }
        }
    }
}
