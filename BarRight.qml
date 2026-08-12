import QtQuick
import qs.Modules

Item {
  id: root
  required property var panelWindow

  Row {
    id: row
    spacing: 2
    rightPadding: 20
    anchors.right: root.right
    height: parent.height
    //width: rText.width + batt.Width
    Battery {
      id: batt
      anchors.verticalCenter: parent.verticalCenter
    }
    SystemTray {
      panelWindow: root.panelWindow
      anchors.verticalCenter: parent.verticalCenter
    }
    Bluetooth {}
  }
}
