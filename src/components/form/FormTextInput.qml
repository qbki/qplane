import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
  id: root
  property alias label: label.text
  property alias text: textField.text

  height: label.height + textField.height

  ColumnLayout {
    anchors.fill: parent

    Label {
      id: label
      Layout.fillWidth: false

      MouseArea {
        anchors.fill: parent
        onClicked: textField.forceActiveFocus()
      }
    }

    TextField {
      id: textField
      Layout.fillWidth: true
    }
  }
}
