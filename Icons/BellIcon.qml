// Generated from SVG file bell.svg
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
            PathSvg { path: "M 10.268 21 Q 10.536 21.4641 11 21.732 Q 11.4641 21.9999 12 21.9999 Q 12.5359 21.9999 13 21.732 Q 13.464 21.4641 13.732 21 " }
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
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg { path: "M 3.262 15.326 Q 3.06182 15.5454 3.01386 15.8385 Q 2.96589 16.1316 3.08571 16.4034 Q 3.20552 16.6752 3.45426 16.8375 Q 3.70299 16.9998 4 17 L 20 17 Q 20.297 17.0001 20.5459 16.8381 Q 20.7948 16.6761 20.9149 16.4045 Q 21.035 16.1329 20.9874 15.8398 Q 20.9399 15.5467 20.74 15.327 Q 19.3908 13.9362 18.8713 12.8365 Q 18 10.9924 18 8 Q 18 5.51472 16.2426 3.75736 Q 14.4853 2 12 2 Q 9.51472 2 7.75736 3.75736 Q 6 5.51472 6 8 Q 6 10.9918 5.12862 12.8364 Q 4.60994 13.9344 3.262 15.326 " }
        }
    }
}
