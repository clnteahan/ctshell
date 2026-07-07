import Quickshell
import QtQuick

Row {
  id: root
  height: parent.height
  width: children.width

  ClockWidget {
    anchors.centerIn: root
  }
}
