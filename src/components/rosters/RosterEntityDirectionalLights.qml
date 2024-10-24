import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property var directionalLightsStore

  id: root

  signal itemAdded(model: entityDirectionalLight)
  signal itemUpdated(model: entityDirectionalLight, initialModel: entityDirectionalLight)

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
      onRightMouseClick: {
        editWindow.open(modelData);
        JS.fireOnce(editWindow.accepted, JS.arity(root.itemUpdated, 2));
      }
    }
  }

  Button {
    text: qsTr("Add Directional Light")
    onClicked: {
      editWindow.open(EntityDirectionalLightFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
