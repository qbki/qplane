pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

RosterBase {
  property string selectedEntityId: ""
  required property AppState appState
  required property var modelsStore

  signal itemClicked(model: entityModel)

  id: root
  name: qsTr("Models")
  factory: EntityModelFactory
  window: Component {
    EntityModelEditWindow {
      modelsDir: root.appState.modelsDir
      projectDir: root.appState.projectDir
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
        name: item.modelData.name
        Layout.fillWidth: true
        Layout.preferredHeight: root.width / 2
        source: item.model.display.path
        selected: root.selectedEntityId === item.modelData.id
        onClicked: function(event) {
          if (event.button === Qt.LeftButton) {
            root.itemClicked(item.modelData);
          } else if (event.button === Qt.RightButton) {
            root.itemClicked(item.modelData);
            root.openContextMenu(item.modelData);
          }
        }
      }
    }
  }
}
