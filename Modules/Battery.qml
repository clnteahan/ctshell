import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import Quickshell.Services.UPower
import qs
import qs.Icons

Row {
  id: root
  readonly property real percent: {
    Math.round(UPower.displayDevice.percentage * 100)
  } 
  readonly property bool charging: {
    UPower.devices.values[0] ? UPower.devices.values[0].state == UPowerDeviceState.Charging : false
  }
  Text {
    anchors.verticalCenter: parent.verticalCenter
    color: Theme.colors.on_background
    id: battText
    text: root.percent + "%"
  }
  Item {
    id: iconWrap
    height: parent.height
    width: 1.6 * height
    readonly property int strokeWidth: width / 24
    Item {
      anchors.left: img.left
      anchors.fill: parent
      anchors.leftMargin: 2 * iconWrap.strokeWidth
      anchors.rightMargin: 6 * iconWrap.strokeWidth
      anchors.margins: 4 * iconWrap.strokeWidth
      Rectangle {
        width: parent.width * (root.percent / 100)
        height: parent.height
        anchors.left: parent.left
        color: root.percent <= 30 ? root.percent <= 20 ? Theme.palettes["error"]["30"] : Theme.palettes["error"]["70"] : Theme.palettes["primary"]["60"]
        enabled: false
      }

    }
    Loader {
      id: img
      anchors.fill: parent
      height: parent.height
      sourceComponent: root.charging ? chargingComponent : batteryComponent
    }
    Component {
      id: batteryComponent
      BatteryIcon {
        color: Theme.colors.on_background
      }
    }
    Component {
      id: chargingComponent
      BatteryChargingIcon {
        color: Theme.colors.on_background
      }
    }
  }
}
