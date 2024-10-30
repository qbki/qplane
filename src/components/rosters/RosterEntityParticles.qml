pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property var particlesStore
  required property var modelsStore

  signal itemAdded(model: entityParticles)
  signal itemUpdated(model: entityParticles, initialModel: entityParticles)

  id: root

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
    delegate: RosterLabel {
      Layout.fillWidth: true
      Layout.fillHeight: true
      onRightMouseClick: {
        editWindow.open(modelData);
        JS.fireOnce(editWindow.accepted, JS.arity(root.itemUpdated, 2));
      }
    }
  }

  Button {
    text: qsTr("Add Particles")
    onClicked: {
      editWindow.open(EntityParticlesFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
