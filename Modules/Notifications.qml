import QtQuick
import QtQuick.Controls
import Quickshell
import qs
import qs.Icons
import qs.Modules

// Notification indicator for the bar: bell + unread count badge
Item {
    id: root

    // Emitted on click so the bar/shell can open a history panel etc.
    signal clicked()

    readonly property int iconSize: height
    implicitWidth: indicatorRow.width + 8
    implicitHeight: 24

    // The popup only exists while there is something to show
    LazyLoader {
        active: NotificationManager.hasNotifications || mouseArea.containsMouse
        NotificationPopup {
          showHistoric: mouseArea.containsMouse
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Row {
        id: indicatorRow
        anchors.centerIn: parent
        spacing: bellIcon.width / -2

        Rectangle {
            id: bellIcon
            width: root.iconSize
            height: root.iconSize
            radius: 4
            color: mouseArea.containsMouse
                   ? Theme.colors.surface_container_high
                   : "transparent"

            BellIcon {
                anchors.fill: parent
                color: Theme.colors.on_background
            }
        }

        Rectangle {
            id: countBadge
            height: bellIcon.height / 2
            width: Math.max(height, countText.implicitWidth + height)
            radius: height
            color: Theme.colors.primary
            visible: NotificationManager.unreadCount > 0 && NotificationManager.showIndicator

            Text {
                id: countText
                anchors.centerIn: parent
                text: NotificationManager.unreadCount > 99 ? "99+" : NotificationManager.unreadCount
                color: Theme.palettes && Theme.palettes["primary"] ? Theme.palettes["primary"]["20"] : "#ffffff"
                font.bold: true
                font.pixelSize: 11
            }

            // Pulse when a new notification arrives
            SequentialAnimation {
                id: pulseAnim
                NumberAnimation { target: countBadge; property: "scale"; to: 1.2; duration: 150 }
                NumberAnimation { target: countBadge; property: "scale"; to: 1.0; duration: 150 }
            }
        }
    }

    Connections {
        target: NotificationManager
        function onUnreadCountChanged() {
            if (NotificationManager.unreadCount > 0)
                pulseAnim.restart()
        }
    }

    ToolTip {
        text: NotificationManager.unreadCount === 0
              ? qsTr("No notifications")
              : qsTr("%1 unread notification(s)").arg(NotificationManager.unreadCount)
        visible: mouseArea.containsMouse
        delay: 1000
    }
}
