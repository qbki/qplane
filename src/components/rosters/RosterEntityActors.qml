pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

GroupBox {
  property string selectedEntityId: ""
  required property var modelsStore
  required property var weaponsStore
  required property var actorsStore
  required property var particlesStore

  signal itemClicked(model: entityActor)
  signal itemAdded(model: entityActor)
  signal itemUpdated(model: entityActor, initialModel: entityActor)
  signal itemRemoved(model: entityActor)

  id: root
  label: RosterTitle {
    text: qsTr("Actors")
    groupBox: root
    onButtonClicked: inner.openAddWindow()
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

  RosterContextMenu {
    id: contextMenu
    onAdded: inner.openAddWindow()
    onEdited: function(model) {
      editWindow.open(model);
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemUpdated, 2));
    }
    onRemoved: function(model) {
      root.itemRemoved(model);
    }
  }

  ColumnLayout {
    anchors.fill: parent

    Repeater {
      model: root.actorsStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        background: Rectangle {
          anchors.fill: parent
          visible: rosterLabel.modelData.id === root.selectedEntityId
          color: palette.highlight
        }
        onLeftMouseClick: {
          root.itemClicked(rosterLabel.modelData);
        }
        onRightMouseClick: {
          root.itemClicked(rosterLabel.modelData);
          contextMenu.open(rosterLabel.modelData);
        }
      }
    }
  }

  QtObject {
    id: inner
    function openAddWindow() {
      editWindow.open(EntityActorFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
