import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  property string selectedEntityId: ""
  required property var modelsStore
  required property var weaponsStore
  required property var actorsStore
  required property var particlesStore

  signal itemClicked(model: entityActor)

  id: root

  component ActorDelegate: Label {
    required property int index
    required property var model
    property entityActor modelData: model.display

    Layout.fillWidth: true
    Layout.fillHeight: true
    text: modelData.id
    font.pointSize: 16

    background: Rectangle {
      anchors.fill: parent
      visible: modelData.id === root.selectedEntityId
      color: palette.highlight
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
      onClicked: function(event) {
        if (event.button === Qt.LeftButton) {
          root.itemClicked(parent.modelData);
        } else if (event.button === Qt.RightButton) {
          editWindow.open(modelData)
          const updateActor = JS.partial(JS.updateEntity, root.actorsStore)
          JS.fireOnce(editWindow.accepted, updateActor);
        }
      }
    }
  }

  SystemPalette {
    id: palette
  }

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityActorEditWindow {
        modelsList: root.modelsStore.toArray().map((v) => v.id)
        weaponsList: root.weaponsStore.toArray().map((v) => v.id)
        particlesList: root.particlesStore.toArray().map((v) => v.id)
      }
    }
  }

  Repeater {
    model: root.actorsStore
    delegate: ActorDelegate {}
  }

  Button {
    text: qsTr("Add Actor")
    onClicked: {
      editWindow.open(EntityActorFactory.create());
      const addActor = (entity) => root.actorsStore.append(entity);
      JS.fireOnce(editWindow.accepted, addActor);
    }
  }
}
