import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  property alias model: lightField.model

  signal canceled()
  signal accepted(newLight: var, light: var)

  id: root
  title: qsTr("Level settings")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  /**
   * @param value.cameraPosition vector3d
   * @param value.globalLightId string
   */
  function open(value: var) {
    lightField.value = value.globalLightId;
    cameraPositionField.value = value.cameraPosition;
    internal.initialData = value;
    root.show();
  }

  QtObject {
    id: internal
    property var initialData
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
      const value = {
        cameraPosition: cameraPositionField.value,
        globalLightId: lightField.value,
      };
      root.accepted(value, internal.initialData);
      root.close();
    }
  }

  FormComboBoxInput {
    id: lightField
    label: qsTr("Directional light")
    Layout.fillWidth: true
  }

  FormVector3DInput {
    id: cameraPositionField
    label: qsTr("Default camera position")
    Layout.fillWidth: true
  }
}
