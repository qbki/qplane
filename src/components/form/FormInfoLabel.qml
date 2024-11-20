pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import app

Item {
  id: root
  property alias label: label.text
  property alias value: valueField.text

  height: label.height + layout.spacing + valueField.height

  Clipboard {
    id: clipboard
  }

  RowLayout {
    anchors.fill: parent

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      ColumnLayout {
        id: layout
        anchors.fill: parent

        Label {
          id: label
        }

        Label {
          id: valueField
        }
      }
    }

    Button {
      id: button
      icon.name: "edit-copy"
      Layout.preferredHeight: 30
      Layout.preferredWidth: 30
      onClicked: clipboard.copy(root.value);
    }
  }
}
