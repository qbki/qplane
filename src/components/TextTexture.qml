pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

import app
import "../jsutils/utils.mjs" as JS

Node {
  required property entityText entity
  required property string text
  property alias pickable: model.pickable
  property alias instancing: model.instancing

  id: root
  onTextChanged: inner.updateTexture()
  Component.onCompleted: inner.updateTexture()

  TextMetrics {
    id: metrics
    text: root.text
  }

  Model {
    id: model
    source: "#Rectangle"
    scale: Qt.vector3d(inner.scaleFactor, inner.scaleFactor, inner.scaleFactor)
    materials: [
      DefaultMaterial {
        diffuseMap: inner.texture
      }
    ]
  }

  QtObject {
    id: inner

    property string oldText: ""
    property var texture: null
    property real scaleFactor: 0.01

    property var textFactory: QmlUtils.createComponent("QtQuick", "Text")
    property var textureFactory: QmlUtils.createComponent("QtQuick3D", "Texture")

    function createInstance(): Texture {
      const textInstance = inner.textFactory(null, {
        text: root.text,
        color: root.entity.color,
        font: { pointSize: root.entity.size },
      });
      const textureInstance = inner.textureFactory(null, { sourceItem: textInstance });
      return textureInstance;
    }

    function updateTexture() {
      const text = root.text;
      const entity = root.entity;

      if (JS.areStrsEqual(text, inner.oldText)) {
        return;
      }

      inner.oldText = text;
      metrics.text = text;
      metrics.font.pointSize = entity.size;

      const ratio = metrics.width / (metrics.height ? metrics.height : 1);
      let width = 1;
      let height = 1;
      if (entity.width && entity.height) {
        width = entity.width;
        height = entity.height;
      } else if (entity.width) {
        width = entity.width;
        height = entity.width / ratio;
      } else if (entity.height) {
        height = entity.height;
        width = entity.height * ratio;
      }

      model.scale = Qt.vector3d(width * inner.scaleFactor,
                                height * inner.scaleFactor,
                                inner.scaleFactor)
      inner.texture = inner.createInstance();
    }
  }
}
