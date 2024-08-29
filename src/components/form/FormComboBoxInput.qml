import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel as Platform

Item {
  property alias label: label.text
  property alias model: comboBox.model
  property alias textRole: comboBox.textRole
  property var value;

  id: root
  height: label.height + comboBox.height

  onValueChanged: {
    comboBox.currentIndex = comboBox.find(root.value);
  }

  ColumnLayout {
    anchors.fill: parent

    Label {
      id: label
      Layout.fillWidth: false

      MouseArea {
        anchors.fill: parent
        onClicked: comboBox.forceActiveFocus()
      }
    }

    ComboBox {
      id: comboBox
      Layout.fillWidth: true
      onCurrentValueChanged: {
        root.value = comboBox.currentValue;
      }
    }
  }
}
