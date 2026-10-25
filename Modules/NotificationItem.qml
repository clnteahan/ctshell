import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs
import qs.Modules

// Individual notification card shown in the popup
Item {
    id: root
    required property var notification
    property bool isHistoryItem: false

    readonly property bool isHovered: hoverHandler.hovered
    readonly property bool hasActions: (notification.actions || []).length > 0

    signal nClosed

    // Width is normally set by the parent column; this is only a default
    implicitWidth: 350
    implicitHeight: contentColumn.implicitHeight + 16

    readonly property color bgColor: {
        if (isHistoryItem) {
            return Theme.colors.surface_container_high
        }
        switch (notification.urgency) {
        case NotificationUrgency.Critical: return Theme.palettes["error"]["50"]
        case NotificationUrgency.Low:      return Theme.colors.surface
        default:                           return Theme.colors.background
        }
    }

    readonly property color borderColor: {
        if (isHistoryItem) {
            return Theme.colors.outline_variant
        }
        switch (notification.urgency) {
        case NotificationUrgency.Critical: return Theme.palettes["error"]["80"]
        case NotificationUrgency.Low:      return Theme.colors.outline_variant
        default:                           return Theme.colors.outline
        }
    }

    // Resolve an icon name or a path/URL to something Image can load
    function iconSource(icon) {
        if (!icon || icon.length === 0) return ""
        if (icon.startsWith("/") || icon.indexOf("://") !== -1) return icon
        return Quickshell.iconPath(icon, true)
    }

    // Safe property accessors for history items
    readonly property string safeAppName: notification.appName || qsTr("Notification")
    readonly property string safeAppIcon: notification.appIcon || ""
    readonly property string safeSummary: notification.summary || ""
    readonly property string safeBody: notification.body || ""
    readonly property var safeActions: notification.actions || []
    readonly property bool safeHasInlineReply: notification.hasInlineReply || false
    readonly property string safeInlineReplyPlaceholder: notification.inlineReplyPlaceholder || ""
    readonly property string safeImage: notification.image || ""

    // Close the card (user action). History is recorded by NotificationManager
    // when the notification's `closed` signal fires.
    function dismissNow() {
        if (isHistoryItem) {
            // For history items, remove from history
            NotificationManager.removeFromHistory(notification.id)
        } else {
            // For active notifications, dismiss them
            dismissTimer.stop()
            if (notification.dismiss) {
                notification.dismiss()
            }
            NotificationManager.dismissNotification(notification.id)
        }
        nClosed()
    }
    function expireNow() {
        if (!isHistoryItem && notification.expire) {
            notification.expire()
        }
    }

    // Fade in
    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: 200
    }

    // Auto-dismiss timeout in ms (0 = never). Critical notifications always
    // follow the manager's setting; otherwise respect the app's timeout
    // (seconds) and fall back to the per-urgency default.
    // History items don't auto-dismiss.
    readonly property int timeoutMs: {
        if (root.isHistoryItem) return 0
        if (notification.urgency !== NotificationUrgency.Critical && notification.expireTimeout > 0)
            return Math.round(notification.expireTimeout * 1000)
        return NotificationManager.getUrgencyTimeout(notification.urgency)
    }

    Timer {
        id: dismissTimer
        interval: root.timeoutMs
        running: root.timeoutMs > 0 && !root.notification.resident && !root.isHovered && !root.isHistoryItem
        repeat: false
        onTriggered: root.expireNow()
    }

    // Background
    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 12
        color: root.bgColor
        border.width: 1
        border.color: closeButton.hovered ? Theme.colors.primary : root.borderColor
    }

    // Hover + click handling. Handlers (unlike a MouseArea on top) don't
    // swallow clicks meant for the buttons and text field.
    HoverHandler {
        id: hoverHandler
    }
    TapHandler {
        onTapped: {
            if (!root.isHistoryItem && !root.hasActions && !root.safeHasInlineReply)
                root.dismissNow()
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
        spacing: 8

        // Header: icon, app name + summary, close button
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop

                Image {
                    id: appIcon
                    anchors.fill: parent
                    source: root.iconSource(root.safeAppIcon)
                    sourceSize: Qt.size(48, 48)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: status === Image.Ready
                }

                // Fallback: first letter of the app name
                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: Theme.colors.background
                    visible: appIcon.status !== Image.Ready

                    Text {
                        anchors.centerIn: parent
                        text: root.safeAppName
                              ? root.safeAppName.charAt(0).toUpperCase() : "?"
                        color: Theme.colors.on_background
                        font.bold: true
                        font.pixelSize: 12
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.safeAppName
                    color: Theme.colors.on_background
                    font.bold: true
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.safeSummary
                    color: Theme.colors.on_background
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    visible: root.safeSummary.length > 0
                }
            }

            Button {
                id: closeButton
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                flat: true
                hoverEnabled: true
                padding: 0
                background: Rectangle { radius: 12; color: "transparent" }
                contentItem: Text {
                    text: root.isHistoryItem ? "✕" : "✕"
                    color: Theme.colors.on_background
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                ToolTip {
                    text: root.isHistoryItem ? qsTr("Clear from history") : qsTr("Dismiss")
                    delay: 500
                }
                onClicked: root.dismissNow()
            }
        }

        // Body
        Text {
            Layout.fillWidth: true
            text: root.safeBody
            color: Theme.colors.on_background
            font.pixelSize: 13
            lineHeight: 1.4
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            visible: root.safeBody.length > 0
        }

        // Image
        Image {
            id: notifImage
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            source: root.safeImage
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: root.safeImage.length > 0 && status === Image.Ready
        }

        // Action buttons - only for active notifications
        Flow {
            Layout.fillWidth: true
            spacing: 8
            visible: !root.isHistoryItem && root.safeActions.length > 0

            Repeater {
                model: root.safeActions

                Button {
                    id: actionButton
                    required property var modelData

                    text: modelData.text
                    flat: true
                    hoverEnabled: true
                    padding: 6
                    background: Rectangle {
                        radius: 6
                        color: actionButton.hovered ? Theme.colors.primary_container : "transparent"
                        border.color: Theme.colors.outline
                        border.width: 1
                    }
                    contentItem: Text {
                        text: actionButton.text
                        color: Theme.colors.on_background
                        font.pixelSize: 12
                    }
                    onClicked: modelData.invoke()
                }
            }
        }

        // Inline reply - only for active notifications
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: !root.isHistoryItem && root.safeHasInlineReply

            TextField {
                id: replyField
                Layout.fillWidth: true
                placeholderText: root.safeInlineReplyPlaceholder || qsTr("Reply...")
                color: Theme.colors.on_surface
                font.pixelSize: 13
                padding: 8
                background: Rectangle {
                    radius: 6
                    color: Theme.colors.surface_container_highest
                    border.color: Theme.colors.outline
                    border.width: 1
                }
                onAccepted: sendButton.clicked()
            }

            Button {
                id: sendButton
                text: qsTr("Send")
                flat: true
                enabled: replyField.text.length > 0
                padding: 8
                background: Rectangle {
                    radius: 6
                    color: sendButton.enabled
                           ? Theme.colors.primary
                           : Theme.colors.surface_container
                }
                contentItem: Text {
                    text: sendButton.text
                    color: sendButton.enabled
                           ? Theme.colors.on_primary
                           : Theme.colors.on_surface_variant
                    font.pixelSize: 12
                }
                onClicked: {
                    if (root.notification.sendInlineReply) {
                        root.notification.sendInlineReply(replyField.text)
                        replyField.text = ""
                    }
                }
            }
        }
    }
}
