pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

GroupBox {
  required property AppState appState
  required property var weaponsStore
  required property var modelsStore

  signal itemAdded(model: entityWeapon)
  signal itemUpdated(model: entityWeapon, initialModel: entityWeapon)
  signal itemRemoved(model: entityWeapon)

  id: root
  label: RosterTitle {
    text: qsTr("Weapons")
    groupBox: root
    onButtonClicked: inner.openAddWindow()
  }

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityWeaponEditWindow {
        soundsDir: root.appState.soundsDir
        projectDir: root.appState.projectDir
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
      model: root.weaponsStore
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
      editWindow.open(EntityWeaponFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
