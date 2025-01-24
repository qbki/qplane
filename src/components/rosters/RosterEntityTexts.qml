pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

RosterBase {
  required property url translationPath
  required property GadgetListModel textsStore
  property string selectedEntityId: ""

  signal itemClicked(model: entityText)

  id: root
  name: qsTr("Texts")
  factory: EntityTextFactory
  window: Component {
    EntityTextEditWindow {
      translationPath: root.translationPath
      textsList: root.textsStore.toArray()
    }
  }

  SystemPalette {
    id: palette
  }

  ColumnLayout {
    Repeater {
      model: root.textsStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        background: Rectangle {
          anchors.fill: parent
          visible: rosterLabel.modelData.id === root.selectedEntityId
          color: palette.highlight
        }
        onLeftMouseClick: {
          root.itemClicked(rosterLabel.modelData);
        }
        onRightMouseClick: {
          root.itemClicked(rosterLabel.modelData);
          root.openContextMenu(rosterLabel.modelData)
        }
      }
    }
  }
}
