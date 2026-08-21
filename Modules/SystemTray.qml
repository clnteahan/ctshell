import QtQuick
import QtQuick.Controls
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs
import qs.Modules

Row {
  id: root

  // The Bar's PanelWindow, needed so right-click context menus can be
  // positioned relative to it via SystemTrayItem.display().
  required property var panelWindow

  spacing: 2

  Repeater {
    model: SystemTray.items

    Item {
      id: trayIcon
      required property var modelData

      width: 24
      height: 24
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? Theme.colors.surface_container_high : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
      }

      Loader {
        id: loader
        sourceComponent: trayIcon.modelData.title === "blueman" ? btIcon : icon
        anchors.centerIn: parent
      }

      Component {
        id: btIcon
        Bluetooth {
          scale: 0.6
        }

      }
      Component {
        id: icon
        IconImage {
          anchors.centerIn: parent
          implicitSize: 16
          asynchronous: true
          source: trayIcon.modelData.icon
        }
      }

      MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
          if (mouse.button === Qt.LeftButton) {
            trayIcon.modelData.activate()
          } else if (mouse.button === Qt.MiddleButton) {
            trayIcon.modelData.secondaryActivate()
          } else if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
            const pos = trayIcon.mapToItem(null, mouse.x, mouse.y)
            trayIcon.modelData.display(root.panelWindow, pos.x, pos.y)
          }
        }

        onWheel: wheel => trayIcon.modelData.scroll(wheel.angleDelta.y, false)
      }

      ToolTip.visible: mouseArea.containsMouse && trayIcon.modelData.title.length > 0
      ToolTip.text: trayIcon.modelData.title
      ToolTip.delay: 1000
    }
  }
}
