import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

OpacityHover {
  property alias position: positionField.value

  id: root
  width: 150
  height: pane.height

  SystemPalette {
    id: palette
  }

  Pane {
    id: pane
    width: root.width
    padding: Theme.spacing(1)
    background: Rectangle {
      radius: Theme.spacing(1)
      color: palette.window
    }

    ColumnLayout {
      id: layout
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: Theme.spacing(1)

      FormVector3DInput {
        id: positionField
        Layout.fillWidth: true
        label: qsTr("Position")
      }
    }
  }
}
