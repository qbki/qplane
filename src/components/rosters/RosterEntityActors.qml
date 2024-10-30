pragma ComponentBehavior: Bound
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
  signal itemAdded(model: entityActor)
  signal itemUpdated(model: entityActor, initialModel: entityActor)

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
      id: rosterLabel
      Layout.fillWidth: true
      Layout.fillHeight: true

      background: Rectangle {
        anchors.fill: parent
        visible: rosterLabel.modelData.id === root.selectedEntityId
        color: palette.highlight
      }

      onLeftMouseClick: {
        root.itemClicked(modelData);
      }
      onRightMouseClick: {
        editWindow.open(modelData);
        JS.fireOnce(editWindow.accepted, JS.arity(root.itemUpdated, 2));
      }
    }
  }

  Button {
    text: qsTr("Add Actor")
    onClicked: {
      editWindow.open(EntityActorFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
