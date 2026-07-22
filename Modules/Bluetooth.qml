import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import qs
import Quickshell.Bluetooth

Item {
  id: root
  property int state: Bluetooth.defaultAdapter.enabled
  anchors.verticalCenter: parent.verticalCenter
  implicitHeight: parent.implicitHeight
  implicitWidth: state ? img.width / img.height * height : 0
  Component.onCompleted: {
      console.debug("Dimensions: ", width, height)
  }

  VectorImage {
    id: img
    preferredRendererType: VectorImage.CurveRenderer
    source: "../Icons/bluetooth.svg"
    visible: false
    enabled: false
  }
  MultiEffect {
    anchors.fill: parent
    source: img
    colorization: 1.0
    colorizationColor: Theme.colors.on_background
    visible: root.state
  }
}
