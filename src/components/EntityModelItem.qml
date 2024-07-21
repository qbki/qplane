import QtQuick

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Item {
  id: root

  required property url source
  required property bool selected

  signal clicked(event: MouseEvent)

  HoverHandler {
    id: hover
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    cursorShape: root.selected ? Qt.ArrowCursor : Qt.PointingHandCursor
    acceptedButtons: Qt.AllButtons
    onClicked: function(event) {
      root.clicked(event)
    }
  }

  View3D {
    anchors.fill: parent
    environment: SceneEnvironment {
      backgroundMode: SceneEnvironment.Color
      antialiasingMode: SceneEnvironment.MSAA
      clearColor: "#dddddd"
    }

    DirectionalLight {
      eulerRotation: Qt.vector3d(-30, -20, -40)
      ambientColor: "#333"
    }

    PerspectiveCamera {
      id: camera
      fieldOfView: 60
      clipNear: 0.001
      clipFar: 1000
    }

    RuntimeLoader {
      id: loader
      source: root.source
      onBoundsChanged: {
        const length = bounds.maximum.minus(bounds.minimum).length();
        const center = bounds.maximum.plus(bounds.minimum).times(0.5);
        camera.position = Qt.vector3d(center.x, center.y, bounds.maximum.z + length);
        camera.lookAt(Qt.vector3d(center.x, center.y, 0));
      }
      onStatusChanged: {
        if (status === RuntimeLoader.Error) {
          console.error(errorString);
        }
      }
    }
  }

  Rectangle {
    visible: root.selected || hover.hovered
    color: "transparent"
    width: root.width
    height: root.height
    border.color: "green"
    border.width: 4
  }
}
