import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property var particlesStore
  required property var modelsStore

  signal itemClicked(model: entityParticles)

  id: root

  component Delegate: Label {
    required property int index
    required property var model
    property entityParticles modelData: model.display

    Layout.fillWidth: true
    Layout.fillHeight: true
    text: modelData.id
    font.pointSize: 16

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
      onClicked: function(event) {
        if (event.button === Qt.LeftButton) {
          root.itemClicked(parent.modelData);
        } else if (event.button === Qt.RightButton) {
          editWindow.open(modelData)
          const updateEntity = JS.partial(JS.updateEntity, root.particlesStore)
          JS.fireOnce(editWindow.accepted, updateEntity);
        }
      }
    }
  }

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityParticlesEditWindow {
        modelsList: root.modelsStore.toArray().map((v) => v.id)
      }
    }
  }

  Repeater {
    model: root.particlesStore
    delegate: Delegate {}
  }

  Button {
    text: qsTr("Add Particles")
    onClicked: {
      editWindow.open(EntityParticlesFactory.create());
      const addEntity = (entity) => root.particlesStore.append(entity);
      JS.fireOnce(editWindow.accepted, addEntity);
    }
  }
}
