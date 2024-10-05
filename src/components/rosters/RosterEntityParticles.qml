import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property var particlesStore
  required property var modelsStore

  signal itemClicked(model: entityParticles)

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

      onLeftMouseClick: root.itemClicked(parent.modelData)
      onRightMouseClick: {
        editWindow.open(modelData);
        const updateEntity = JS.partial(JS.updateEntity, root.particlesStore);
        JS.fireOnce(editWindow.accepted, updateEntity);
      }
    }
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
