import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
  required property GroupBox groupBox
  property alias text: label.text

  signal buttonClicked

  id: root
  x: groupBox.leftPadding
  width: groupBox.availableWidth

  Label {
    id: label
    Layout.fillWidth: true
  }
  Button {
    text: "+"
    Layout.preferredHeight: label.height
    Layout.preferredWidth: label.height
    onClicked: root.buttonClicked()
  }
}
