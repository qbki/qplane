import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  required property AppState appState
  required property var weaponsStore
  required property var modelsStore

  signal itemClicked(model: entityWeapon)

  id: root

  component Delegate: Label {
    required property int index
    required property var model
    property entityWeapon modelData: model.display

    Layout.fillWidth: true
    Layout.fillHeight: true
    text: modelData.id
    font.pointSize: 16

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
      onClicked: function(event) {
        if (event.button === Qt.LeftButton) {
          root.itemClicked(parent.modelData);
        } else if (event.button === Qt.RightButton) {
          editWindow.open(modelData)
          const updateEntity = JS.partial(JS.updateEntity, root.weaponsStore)
          JS.fireOnce(editWindow.accepted, updateEntity);
        }
      }
    }
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

  Repeater {
    model: root.weaponsStore
    delegate: Delegate {}
  }

  Button {
    text: qsTr("Add Weapon")
    onClicked: {
      editWindow.open(EntityWeaponFactory.create());
      const addEntity = (entity) => {
        root.weaponsStore.append(entity);
      };
      JS.fireOnce(editWindow.accepted, addEntity);
    }
  }
}
