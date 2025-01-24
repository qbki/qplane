import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import "qrc:/jsutils/utils.mjs" as JS
import app

Item {
  property alias label: label.text
  property color value: inner.defaultColor
  property alias errorMessage: errorMessage.text

  id: root
  implicitHeight: (label.height
                   + layout.spacing
                   + textField.height
                   + errorMessage.getAdaptiveHeight(layout.spacing))

  onValueChanged: {
    let textFieldColor = inner.defaultColor;
    try {
      textFieldColor = Qt.color(textField.text);
    } catch(err) {
      JS.noop();
    }
    if (!textField.focus && !Qt.colorEqual(root.value, textFieldColor)) {
      textField.text = root.value.toString();
    }
    if (!Qt.colorEqual(root.value, colorDialog.selectedColor)) {
      colorDialog.selectedColor = root.value.valid ? root.value : inner.defaultColor;
    }
  }

  Component.onCompleted: {
    if (!textField.text) {
      textField.text = root.value;
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
            root.value = QmlConsts.INVALID_COLOR;
          }
        }
      }

      Rectangle {
        id: rectangle
        color: root.value.valid ? root.value : inner.defaultColor
        radius: 2
        Layout.fillWidth: true
        Layout.fillHeight: true

        Text {
          anchors.centerIn: rectangle
          color: Theme.errorColor
          text: qsTr("Invalid!")
          visible: !root.value.valid
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            colorDialog.open();
          }
        }
      }
    }

    InputErrorMessage {
      id: errorMessage
    }
  }

  ColorDialog {
    id: colorDialog
    onAccepted: {
      textField.text = colorDialog.selectedColor.toString();
      root.value = colorDialog.selectedColor;
    }
  }

  QtObject {
    id: inner
    property color defaultColor: Qt.color("#000000")
  }
}
