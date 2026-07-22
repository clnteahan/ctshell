import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import Quickshell.Services.UPower
import qs

Row {
  id: root
  readonly property real percent: {
    Math.round(UPower.displayDevice.percentage * 100)
  } 
  readonly property bool charging: {
    UPower.devices.values[0].state == UPowerDeviceState.Charging
  }
  Text {
    color: Theme.colors.on_background
    id: battText
    text: root.percent + "%"
  }
  Item {
    id: iconWrap
    width: 1.4 * battText.height
    height: 0.95 * battText.height
    Rectangle {
      width: img.width * 0.75 * (root.percent / 100)
      height: img.height * 0.49
      anchors.horizontalCenterOffset: root.percent / -100
      anchors.verticalCenter: img.verticalCenter
      anchors.left: img.left
      color: root.percent <= 30 ? root.percent <= 20 ? Theme.palettes["error"]["30"] : Theme.palettes["error"]["70"] : Theme.palettes["primary"]["60"]
      enabled: false
    }
    VectorImage {
      id: img
      anchors.fill: parent
      preferredRendererType: VectorImage.CurveRenderer
      source: root.charging ? "../Icons/battery-charging.svg" : "../Icons/battery.svg"
      visible: false
      enabled: false
    }
    MultiEffect {
      anchors.fill: parent
      source: img
      colorization: 1.0
      colorizationColor: Theme.colors.on_background
    }
  }
}
