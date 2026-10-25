import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs
import qs.Modules

// Overlay window that shows active and expired notifications.
// Create it through a LazyLoader (see Notifications.qml).
PanelWindow {
    id: root

    // 0 = top-right, 1 = top-left, 2 = bottom-right, 3 = bottom-left
    readonly property int pos: NotificationManager.position
    property bool showHistoric: false
    signal nClosed()

    // Show popup if there are active notifications OR history (when showHistoric is true)
    visible: NotificationManager.hasNotifications || (showHistoric && NotificationManager.history.length > 0)
    
    // Track when mouse enters/exits the popup
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

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

    color: showHistoric ? Theme.colors.surface_container : "transparent"
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

        // Active notifications section
        Repeater {
            model: NotificationManager.activeNotifications

            delegate: NotificationItem {
                required property var modelData
                notification: modelData
                width: contentColumn.width
                isHistoryItem: false
                onNClosed: {
                  if (NotificationManager.history.length == 0 && NotificationManager.hasNotifications) {
                    root.nClosed()
                  }
                }
            }
        }

        // History header - only shown when viewing history
        Item {
            visible: showHistoric && NotificationManager.history.length > 0
            height: NotificationManager.activeNotifications.length > 0 ? 20 : 0
            width: contentColumn.width

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 120
                height: 1
                color: Theme.colors.outline
                radius: 0.5
            }

            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                text: qsTr("Expired Notifications")
                color: Theme.colors.on_surface_variant
                font.pixelSize: 12
                font.bold: true
            }
        }

        // History notifications section
        Repeater {
            model: showHistoric ? NotificationManager.history : []

            delegate: NotificationItem {
                required property var modelData
                notification: modelData
                width: contentColumn.width
                isHistoryItem: true
                onNClosed: {
                  if (NotificationManager.history.length == 0 && NotificationManager.hasNotifications) {
                    root.nClosed()
                  }
                }
            }
        }

        // Dismiss All button - only shown when viewing history
        Item {
            visible: showHistoric && (NotificationManager.hasNotifications || NotificationManager.history.length > 0)
            width: contentColumn.width
            height: 36

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Dismiss All")
                flat: true
                hoverEnabled: true
                padding: 6
                background: Rectangle {
                    radius: 6
                    color: hoverHandler.hovered ? Theme.colors.primary_container : "transparent"
                    border.color: Theme.colors.outline
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: Theme.colors.on_background
                    font.pixelSize: 12
                }
                onClicked: {
                  root.nClosed()
                  NotificationManager.dismissAll()
                }

                HoverHandler {
                    id: hoverHandler
                }
            }
        }
    }
}
