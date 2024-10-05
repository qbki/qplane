import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property var directionalLightsStore

  signal itemClicked(model: entityDirectionalLight)

  id: root

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityDirectionalLightEditWindow {}
    }
  }

  Repeater {
    model: root.directionalLightsStore
    delegate: RosterLabel {
      Layout.fillWidth: true
      Layout.fillHeight: true
      onLeftMouseClick: root.itemClicked(parent.modelData)
      onRightMouseClick: {
        editWindow.open(modelData);
        const updateEntity = JS.partial(JS.updateEntity, root.directionalLightsStore);
        JS.fireOnce(editWindow.accepted, updateEntity);
      }
    }
  }

  Button {
    text: qsTr("Add Directional Light")
    onClicked: {
      editWindow.open(EntityDirectionalLightFactory.create());
      const addEntity = (entity) => root.directionalLightsStore.append(entity);
      JS.fireOnce(editWindow.accepted, addEntity);
    }
  }
}
