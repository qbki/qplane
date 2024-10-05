import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

ColumnLayout {
  property string selectedEntityId: ""
  required property AppState appState
  required property var modelsStore

  signal itemClicked(model: entityModel)

  id: root

  LazyEditWindow {
    id: editWindow
    window: Component {
      EntityModelEditWindow {
        modelsDir: root.appState.modelsDir
        projectDir: root.appState.projectDir
      }
    }
  }

  GridLayout {
    columns: 2
    rowSpacing: 1
    columnSpacing: 1
    uniformCellWidths: true
    uniformCellHeights: true
    Layout.fillWidth: true

    Repeater {
      model: root.modelsStore

      EntityModelItem {
        required property var model
        property entityModel modelData: model.display
        id: item
        name: modelData.id
        Layout.fillWidth: true
        Layout.preferredHeight: root.width / 2
        source: modelData.path
        selected: root.selectedEntityId === modelData.id
        onClicked: function(event) {
          if (event.button === Qt.LeftButton) {
            itemClicked(modelData);
          } else if (event.button === Qt.RightButton) {
            editWindow.open(modelData);
            const updateModel = JS.partial(JS.updateEntity, root.modelsStore)
            JS.fireOnce(editWindow.accepted, updateModel);
          }
        }
      }
    }
  }

  Button {
    text: qsTr("Add Model")
    onClicked: {
      editWindow.open(EntityModelFactory.create());
      const addModel = (entity) => root.modelsStore.append(entity);
      JS.fireOnce(editWindow.accepted, addModel);
    }
  }
}
