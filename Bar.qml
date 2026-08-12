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
      BarLeft {
        id: barLeft
        anchors.left: parent.left
        anchors.right: barMiddle.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        screen: barWin.screen
      }
      BarRight {
        id: barRight
        anchors.left: barMiddle.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        panelWindow: barWin
      }
      BarMiddle {
        id: barMiddle
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
      }
      color: Theme.colors.background

      implicitHeight: 35
    }
  }
}
