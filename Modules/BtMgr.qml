import QtQuick
import qs
import qs.Icons
import Quickshell.Bluetooth
import Quickshell.Widgets


WrapperItem {
  id: root
  enum BluetoothState { None, Disabled, Enabled, Scanning, Connected }

  property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var connectedDevices: {
    return adapter.devices.values.filter((dev) => {
      return dev.connected
    })
  }

  readonly property int btState: {
    if (!adapter) return BtMgr.BluetoothState.None;
    if (!adapter.enabled) return BtMgr.BluetoothState.Disabled
    if (adapter.discovering) return BtMgr.BluetoothState.Scanning
    if (connectedDevices.length > 0) return BtMgr.BluetoothState.Connected
    return BtMgr.BluetoothState.Enabled
  }

  Loader {
    id: loader
    sourceComponent: {
      switch (root.btState) {
        case BtMgr.BluetoothState.None:
          return noBtComponent;
        case BtMgr.BluetoothState.Disabled:
          return btOffComponent;
        case BtMgr.BluetoothState.Enabled:
          return btOnComponent;
        case BtMgr.BluetoothState.Scanning:
          return btScanningComponent;
        case BtMgr.BluetoothState.Connected:
          return btConnectedComponent;
      }
    }
  }

  Component {
    id: noBtComponent
    BluetoothIcon {
      color: Theme.palettes["error"]["40"]
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
  Component {
    id: btScanningComponent
    BluetoothSearchingIcon {
      color: Theme.colors.on_background
    }
  }
  Component {
    id: btConnectedComponent
    BluetoothConnectedIcon {
      color: Theme.colors.on_background
    }
  }

}

/*
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
*/
