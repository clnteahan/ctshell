import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import Quickshell.Services.UPower
import qs

Row {
  id: root
  Text {
    color: Theme.colors.on_background
    id: battText
    text: Math.round(UPower.devices.values[0].percentage * 100) + "%"
  }
  Item {
    id: iconWrap
    width: 0.95 * battText.height
    height: 0.95 * battText.height

    VectorImage {
      id: img
      anchors.fill: parent
      preferredRendererType: VectorImage.CurveRenderer
      source: "../Icons/battery.svg"
      visible: false
    }
    MultiEffect {
      anchors.fill: parent
      source: img
      colorization: 1.0
      colorizationColor: Theme.palettes["primary"][(Math.round(UPower.devices.values[0].percentage * 10) * 10 + "")]
    }
  }
}
