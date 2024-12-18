import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
  property alias label: label.text
  property alias model: comboBox.model
  property alias textRole: comboBox.textRole
  property alias valueRole: comboBox.valueRole
  property var value;

  id: root
  height: label.height + layout.spacing + comboBox.height

  onValueChanged: {
    comboBox.currentIndex = comboBox.indexOfValue(root.value);
  }

  ColumnLayout {
    id: layout
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
        if (root.value !== comboBox.currentValue) {
          root.value = comboBox.currentValue;
        }
      }
    }
  }
}
