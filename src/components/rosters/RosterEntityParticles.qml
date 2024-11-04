pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

GroupBox {
  required property var particlesStore
  required property var modelsStore

  signal itemAdded(model: entityParticles)
  signal itemUpdated(model: entityParticles, initialModel: entityParticles)
  signal itemRemoved(model: entityParticles)

  id: root
  label: RosterTitle {
    text: qsTr("Particles")
    groupBox: root
    onButtonClicked: inner.openAddWindow()
  }

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityParticlesEditWindow {
        modelsList: root.modelsStore.toArray().map((v) => v.id)
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
    Repeater {
      model: root.particlesStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        onRightMouseClick: contextMenu.open(rosterLabel.modelData)
      }
    }
  }

  QtObject {
    id: inner
    function openAddWindow() {
      editWindow.open(EntityParticlesFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
