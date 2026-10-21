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
    color: Theme.colors.on_background
    id: battText
    text: root.percent + "%"
  }
  Item {
    id: iconWrap
    height: parent.height
    width: 1.6 * height
    Component.onCompleted: {
      console.log("i height:", height)
    }
    Item {
      anchors.fill: parent
      anchors.leftMargin: 2
      anchors.rightMargin: 6
      anchors.margins: 4
      Component.onCompleted: {
        console.log("ii height:", height)
      }
      Rectangle {
        width: parent.width * (root.percent / 100)
        height: parent.height
        anchors.left: img.left
        color: root.percent <= 30 ? root.percent <= 20 ? Theme.palettes["error"]["30"] : Theme.palettes["error"]["70"] : Theme.palettes["primary"]["60"]
        enabled: false
        Component.onCompleted: {
          console.log("r height:", height)
        }
      }

    }
    Loader {
      id: img
      anchors.fill: parent
      height: parent.height
      sourceComponent: root.charging ? chargingComponent : batteryComponent
      Component.onCompleted: {
        console.log("l height:", height)
      }
    }
    Component {
      id: batteryComponent
      BatteryIcon {
        color: Theme.colors.on_background
        Component.onCompleted: {
          console.log("b height:", height)
        }
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
