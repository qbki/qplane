import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
  id: root
  property alias label: label.text
  property alias value: textField.text
  property alias errorMessage: errorMessage.text

  implicitHeight: {
    const errorHeight = errorMessage.getAdaptiveHeight(layout.spacing);
    return label.height + layout.spacing + textField.height + errorHeight;
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

    TextField {
      id: textField
      Layout.fillWidth: true
    }

    InputErrorMessage {
      id: errorMessage
      visible: Boolean(errorMessage.text)
    }
  }
}
