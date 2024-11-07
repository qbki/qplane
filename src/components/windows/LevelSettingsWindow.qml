import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  property alias lightsModel: lightField.model

  signal canceled()
  /**
   * @param value.meta levelMeta
   * @param value.globalLightId string
   */
  signal accepted(value: var)

  id: root
  title: qsTr("Level settings")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  /**
   * @param value.meta levelMeta
   * @param value.globalLightId string
   */
  function open(value: var) {
    lightField.value = value.globalLightId;
    cameraPositionField.value = value.meta.camera.position;
    minBoundaryField.value = value.meta.boundaries.min;
    maxBoundaryField.value = value.meta.boundaries.max;
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
      const meta = LevelMetaFactory.create();
      meta.camera.position = cameraPositionField.value;
      meta.boundaries.min = minBoundaryField.value;
      meta.boundaries.max = maxBoundaryField.value;

      const globalLightId = lightField.value;

      root.accepted({ meta, globalLightId });
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

  FormVector3DInput {
    id: minBoundaryField
    label: qsTr("Minimal boundary")
    Layout.fillWidth: true
  }

  FormVector3DInput {
    id: maxBoundaryField
    label: qsTr("Maximum boundary")
    Layout.fillWidth: true
  }
}
