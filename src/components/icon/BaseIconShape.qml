import QtQuick
import QtQuick.Shapes

Shape {
  property color strokeColor: "black"
  property alias svgPath: path.path

  id: root
  width: 30
  height: 30
  fillMode: Shape.PreserveAspectFit

  ShapePath {
    id: shapePath
    fillColor: "white"
    strokeWidth: 20
    strokeColor: root.strokeColor
    joinStyle: ShapePath.RoundJoin
    capStyle: ShapePath.RoundCap

    PathSvg {
      id: path
    }
  }
}
