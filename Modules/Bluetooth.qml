import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import qs
import qs.Icons
import Quickshell.Bluetooth
import Quickshell.Widgets

WrapperItem {
  id: root
  property int state: {
    if (!Bluetooth.defaultAdapter) return 0
    return Bluetooth.defaultAdapter.enabled
  }

  BluetoothIcon {
    color: Theme.colors.on_background
  }
}
