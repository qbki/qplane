pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

GroupBox {
  required property var directionalLightsStore

  signal itemAdded(model: entityDirectionalLight)
  signal itemUpdated(model: entityDirectionalLight, initialModel: entityDirectionalLight)
  signal itemRemoved(model: entityDirectionalLight)

  id: root
  label: RosterTitle {
    text: qsTr("Directional Light")
    groupBox: root
    onButtonClicked: inner.openAddWindow()
  }

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityDirectionalLightEditWindow {}
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
      model: root.directionalLightsStore
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
      editWindow.open(EntityDirectionalLightFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
