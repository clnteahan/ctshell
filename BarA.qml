import QtQuick
import qs.Modules

Row {
  id: root

  leftPadding: 20
  spacing: 8
  /*Text {
    horizontalAlignment: Text.AlignHCenter
    color: Theme.colors.on_background
    text: "L"
  }*/
  required property var screen

  Workspaces {
    screen: root.screen
    anchors.verticalCenter: parent.verticalCenter
  }
}
