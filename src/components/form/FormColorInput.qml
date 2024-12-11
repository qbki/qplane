import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS

Item {
  property alias label: label.text
  property color value

  id: root
  implicitHeight: label.height + textField.height + layout.spacing

  onValueChanged: {
    let textFieldColor = Qt.color("black");
    try {
      textFieldColor = Qt.color(textField.text);
    } catch(err) {
      JS.noop();
    }
    if (root.value.valid && !Qt.colorEqual(root.value, textFieldColor)) {
      textField.text = root.value.toString();
    }
    if (root.value.valid && !Qt.colorEqual(root.value, colorDialog.selectedColor)) {
      colorDialog.selectedColor = root.value;
    }
  }

  Component.onCompleted: {
    if (!textField.text) {
      textField.text = Qt.color("black");
    }
  }

  ColumnLayout {
    id: layout
    anchors.fill: parent

    Label {
      id: label
      Layout.fillWidth: false

      MouseArea {
        anchors.fill: parent
        onClicked: textField.forceActiveFocus()
      }
    }

    RowLayout {
      Layout.fillWidth: true

      TextField {
        id: textField
        Layout.preferredWidth: 100
        onTextChanged: {
          try {
            const color = Qt.color(textField.text);
            if (!Qt.colorEqual(root.value, color)) {
              root.value = color;
            }
          } catch(err) {
            JS.noop();
          }
        }
      }

      Rectangle {
        color: root.value
        radius: 2
        Layout.fillWidth: true
        Layout.fillHeight: true

        MouseArea {
          anchors.fill: parent
          onClicked: colorDialog.open()
        }
      }
    }
  }

  ColorDialog {
    id: colorDialog
    onAccepted: root.value = colorDialog.selectedColor;
  }
}
