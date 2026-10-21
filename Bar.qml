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
      BarA {
        id: barA
        anchors.left: parent.left
        anchors.right: barB.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        screen: barWin.screen
      }
      BarC {
        id: barC
        anchors.left: barB.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: Math.min(24, parent.height / 4)
        anchors.bottomMargin: anchors.topMargin
        panelWindow: barWin
      }
      BarB {
        id: barB
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
      }
      color: Theme.colors.background

      implicitHeight: 35
    }
  }
}
