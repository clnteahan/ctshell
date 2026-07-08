import QtQuick
import qs.Modules

Item {
  id: root

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
    Text {
      id: rText
      horizontalAlignment: Text.AlignHCenter
      color: Theme.colors.on_background
      text: "R"
    }
  }
}
