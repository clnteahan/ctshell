// Generated from SVG file bluetooth-off.svg
import QtQuick
import QtQuick.VectorImage
import QtQuick.VectorImage.Helpers
import QtQuick.Shapes
import QtQuick.Effects

Item {
    required property var color
    implicitWidth: 24
    implicitHeight: 24
    component AnimationsInfo : QtObject
    {
        property bool paused: false
        property int loops: 1
        signal restart()
    }
    property AnimationsInfo animations : AnimationsInfo {}
    transform: [
        Scale { xScale: width / 24; yScale: height / 24 }
    ]
    id: __qt_toplevel
    Shape {
        id: _qt_node0
        transformOrigin: Item.TopLeft
        ShapePath {
            id: _qt_node1_fill_stroke
            strokeColor: __qt_toplevel.color
            strokeWidth: 2
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            miterLimit: 4
            fillColor: "#00000000"
            fillRule: ShapePath.WindingFill
            PathSvg { path: "M 17 17 L 12 22 L 12 12 L 7 17 " }
        }
        ShapePath {
            id: _qt_node2_fill_stroke
            strokeColor: __qt_toplevel.color
            strokeWidth: 2
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            miterLimit: 4
            fillColor: "#00000000"
            fillRule: ShapePath.WindingFill
            PathSvg { path: "M 2 2 L 22 22 " }
        }
        ShapePath {
            id: _qt_node3_fill_stroke
            strokeColor: __qt_toplevel.color
            strokeWidth: 2
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            miterLimit: 4
            fillColor: "#00000000"
            fillRule: ShapePath.WindingFill
            PathSvg { path: "M 14.5 9.5 L 17 7 L 12 2 L 12 6.5 " }
        }
    }
}
