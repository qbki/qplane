import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  property alias model: lightField.model

  signal canceled()
  signal accepted(newLight: string, light: string)

  id: root
  title: qsTr("Select a global light")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(value: string) {
    lightField.value = value;
    internal.initialData = value;
    root.show();
  }

  QtObject {
    id: internal
    property string initialData
  }

  Action {
    id: cancelHandler
    text: qsTr("Cancel")
    onTriggered: {
      root.canceled();
      root.close();
    }
  }

  Action {
    id: acceptHandler
    text: qsTr("Ok")
    onTriggered: {
      root.accepted(lightField.value, internal.initialData);
      root.close();
    }
  }

  FormComboBoxInput {
    id: lightField
    label: qsTr("Directional light")
    Layout.fillWidth: true
  }
}
