pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property AppState appState
  required property var weaponsStore
  required property var modelsStore

  signal itemAdded(model: entityWeapon)
  signal itemUpdated(model: entityWeapon, initialModel: entityWeapon)

  id: root

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

  Repeater {
    model: root.weaponsStore
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
    text: qsTr("Add Weapon")
    onClicked: {
      editWindow.open(EntityWeaponFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
