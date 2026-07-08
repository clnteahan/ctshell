import Quickshell
import QtQuick
Item {
  id: root
  width: row.implicitWidth
  Row {
    id: row
    spacing: 2
    anchors.fill: parent

    ClockWidget {
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
