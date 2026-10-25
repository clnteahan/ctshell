pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// NOTE: singletons are created lazily. Reference NotificationManager somewhere
// that loads at startup (the bar indicator does) or the server won't be
// running when the first notification arrives.
Singleton {
    id: root

    // Notification server from Quickshell
    NotificationServer {
        id: server

        // Advertise what the UI actually supports
        actionsSupported: true
        imageSupported: true
        inlineReplySupported: true
        bodySupported: true
        bodyMarkupSupported: false   // NotificationItem renders plain text
        keepOnReload: true

        onNotification: notification => {
            // Without this the notification is dropped and never shows up
            notification.tracked = true

            // Record every closed notification (dismissed, expired, or closed by the app)
            notification.closed.connect((reason) => {
                if (notification.transient) return
                if (reason != NotificationCloseReason.Expired) return
                root.addToHistory(notification)
            })
        }
    }

    // Active (tracked) notifications. This is an ObjectModel: use `.values`
    // for the list (it has no count/get).
    readonly property var activeNotifications: server.trackedNotifications
    readonly property int activeCount: activeNotifications.values.length
    readonly property bool hasNotifications: activeCount > 0

    // Notifications received since the indicator was last clicked.
    // (`notification.tracked` is true for *every* tracked notification, so it
    // can't be used to detect "unread".)
    readonly property int unreadCount: activeNotifications.values.length + history.length

    function dismisssAll() {
      for (const n of activeNotifications) {
        n.dismiss()
      }
      history = []
    }

    // Notification history (most recent first)
    property var history: []
    readonly property int maxHistory: 50

    // Settings
    property int position: 0 // 0 = top-right, 1 = top-left, 2 = bottom-right, 3 = bottom-left
    property int timeoutLow: 5000      // ms
    property int timeoutNormal: 10000  // ms
    property int timeoutCritical: 0    // 0 = never auto-dismiss
    property bool showIndicator: true

    // Returns milliseconds; 0 means "never"
    function getUrgencyTimeout(urgency) {
        switch (urgency) {
        case NotificationUrgency.Low: return timeoutLow
        case NotificationUrgency.Normal: return timeoutNormal
        case NotificationUrgency.Critical: return timeoutCritical
        default: return timeoutNormal
        }
    }

    function addToActive(notification) {
        if (!notification)
            return
        // Reassign (not mutate) so bindings on `history` update, and keep the
        // newest entries instead of refusing new ones once full.
        activeNotifications = [{
            id: notification.id,
            appName: notification.appName,
            appIcon: notification.appIcon,
            summary: notification.summary,
            body: notification.body,
            urgency: notification.urgency,
            timestamp: new Date().toISOString()
        }, ...activeNotifications]
    }

    function addToHistory(notification) {
        if (!notification)
            return
        // Reassign (not mutate) so bindings on `history` update, and keep the
        // newest entries instead of refusing new ones once full.
        history = [...history, {
            id: notification.id,
            appName: notification.appName,
            appIcon: notification.appIcon,
            summary: notification.summary,
            body: notification.body,
            urgency: notification.urgency,
            timestamp: new Date().toISOString()
        }].slice(0, maxHistory)
    }

    function clearHistory() {
        history = []
    }

    function removeFromHistory(id) {
      history = history.filter(n => n.id !== id)
    }

    // Dismiss a notification by ID (history is recorded by the `closed` handler)
    function dismissNotification(id) {
        for (const n of activeNotifications.values) {
            if (n.id === id) {
              n.dismiss()
              return true
            }
        }
        removeFromHistory(id)
        return false
    }

    function dismissAll() {
        // Copy first: dismissing mutates the model while we iterate
        for (const n of [...activeNotifications.values])
            n.dismiss()
    }

    function invokeAction(notificationId, actionIdentifier) {
        for (const n of activeNotifications.values) {
            if (n.id !== notificationId)
                continue
            for (const action of n.actions) {
                if (action.identifier === actionIdentifier) {
                    action.invoke()
                    return true
                }
            }
        }
        return false
    }

    function sendInlineReply(notificationId, replyText) {
        for (const n of activeNotifications.values) {
            if (n.id === notificationId && n.hasInlineReply) {
                n.sendInlineReply(replyText)
                return true
            }
        }
        return false
    }
}
