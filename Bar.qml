import Quickshell
import QtQuick.Controls
import QtQuick

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      id: barWin
      
      anchors {
        top: true
        left: true
        right: true
      }
      BarLeft { id: barLeft; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
      BarRight { id: barRight; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter }
      BarMiddle {
        anchors.left: barLeft.right
        anchors.right: barRight.left
        anchors.verticalCenter: parent.verticalCenter
      }
      color: Theme.colors.background

      implicitHeight: 30
    }
  }
}
