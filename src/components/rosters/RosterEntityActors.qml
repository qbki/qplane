import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  property string selectedEntityId: ""
  required property var modelsStore
  required property var weaponsStore
  required property var actorsStore
  required property var particlesStore

  signal itemClicked(model: entityActor)

  id: root

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
    delegate: RosterLabel {
      Layout.fillWidth: true
      Layout.fillHeight: true

      background: Rectangle {
        anchors.fill: parent
        visible: modelData.id === root.selectedEntityId
        color: palette.highlight
      }

      onLeftMouseClick: {
        root.itemClicked(modelData);
      }
      onRightMouseClick: {
        editWindow.open(modelData);
        const updateActor = JS.partial(JS.updateEntity, root.actorsStore);
        JS.fireOnce(editWindow.accepted, updateActor);
      }
    }
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
