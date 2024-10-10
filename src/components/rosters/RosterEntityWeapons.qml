import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property AppState appState
  required property var weaponsStore
  required property var modelsStore

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
        const updateEntity = JS.partial(JS.updateEntity, root.weaponsStore);
        JS.fireOnce(editWindow.accepted, updateEntity);
      }
    }
  }

  Button {
    text: qsTr("Add Weapon")
    onClicked: {
      editWindow.open(EntityWeaponFactory.create());
      const addEntity = (entity) => root.weaponsStore.append(entity);
      JS.fireOnce(editWindow.accepted, addEntity);
    }
  }
}
