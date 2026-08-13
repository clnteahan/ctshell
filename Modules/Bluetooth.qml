import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import qs
import qs.Icons
import Quickshell.Bluetooth
import Quickshell.Widgets

WrapperItem {
  id: root
  readonly property int btState: !Bluetooth.defaultAdapter ? 0
                               : (Bluetooth.defaultAdapter.enabled ? 2 : 1)

  Loader {
    id: loader
    active: root.btState > 0
    sourceComponent: root.btState == 0 ? noBtComponent
                    : root.btState == 1 ? btOffComponent
                    : root.btState == 2 ? btOnComponent : null
  }

  Component {
    id: noBtComponent
    BluetoothIcon {
      color: Theme.palettes["neutral"]["40"]
    }
  }
  Component {
    id: btOffComponent
    BluetoothOffIcon {
      color: Theme.colors.on_background
    }
  }
  Component {
    id: btOnComponent
    BluetoothIcon {
      color: Theme.colors.on_background
    }
  }

}
