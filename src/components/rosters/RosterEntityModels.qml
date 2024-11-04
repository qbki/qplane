pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS
import app

GroupBox {
  property string selectedEntityId: ""
  required property AppState appState
  required property var modelsStore

  signal itemClicked(model: entityModel)
  signal itemAdded(model: entityModel)
  signal itemUpdated(model: entityModel, initialModel: entityModel)
  signal itemRemoved(model: entityModel)

  id: root
  label: RosterTitle {
    text: qsTr("Models")
    groupBox: root
    onButtonClicked: inner.openAddWindow()
  }

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
    anchors.fill: parent

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
            root.itemClicked(item.modelData);
          } else if (event.button === Qt.RightButton) {
            root.itemClicked(item.modelData);
            contextMenu.open(item.modelData);
          }
        }
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

  QtObject {
    id: inner
    function openAddWindow() {
      editWindow.open(EntityModelFactory.create());
      JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    }
  }
}
