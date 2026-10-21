// Generated from SVG file battery-charging.svg
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
    Item {
        width: 1
        height: 1
        ItemSpy { id: __qt_toplevel_scale_itemspy; anchors.fill: parent }
    }
    transform: [
        Scale { xScale: width / 24; yScale: height / 24 }
    ]
    id: __qt_toplevel
    Shape {
        preferredRendererType: Shape.CurveRenderer
        id: _qt_node0
        transformOrigin: Item.TopLeft
        ShapePath {
            id: _qt_node1_stroke
            strokeColor: __qt_toplevel.color
            strokeWidth: 2
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            miterLimit: 4
            fillColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic
            PathSvg { path: "M 5 18 L 3 18 Q 2.17157 18 1.58579 17.4142 Q 1 16.8284 1 16 L 1 8 Q 1 7.17157 1.58579 6.58579 Q 2.17157 6 3 6 L 6.19 6 M 15 6 L 17 6 Q 17.8284 6 18.4142 6.58579 Q 19 7.17157 19 8 L 19 16 Q 19 16.8284 18.4142 17.4142 Q 17.8284 18 17 18 L 13.81 18 " }
        }
        ShapePath {
            id: _qt_node2_stroke
            strokeColor: __qt_toplevel.color
            strokeWidth: 2
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            miterLimit: 4
            fillColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic
            PathSvg { path: "M 23 13 L 23 11 " }
        }
        ShapePath {
            id: _qt_node3_stroke
            strokeColor: __qt_toplevel.color
            strokeWidth: 2
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            miterLimit: 4
            fillColor: "transparent"
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic
            PathSvg { path: "M 11 6 L 7 12 L 13 12 L 9 18 " }
        }
    }
}
