pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root
  readonly property string name: Quickshell.env("XDG_CURRENT_DESKTOP");
}
