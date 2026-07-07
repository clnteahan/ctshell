import QtQuick
import qs.Modules

Flow {
  rightPadding: 20
  //width: rText.width + batt.Width
  Battery {
    id: batt
  }
  Text {
    id: rText
    horizontalAlignment: Text.AlignHCenter
    color: Theme.colors.on_background
    text: "R"
  }
}
