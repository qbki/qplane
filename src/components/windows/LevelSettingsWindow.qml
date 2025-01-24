import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  property list<entityDirectionalLight> directionalLightsList: []

  signal canceled()
  /**
   * @param {Object} value
   * @param {levelMeta} value.meta
   * @param {string} value.globalLightId
   */
  signal accepted(value: var)

  id: root
  title: qsTr("Level settings")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  /**
   * @param {Object} value
   * @param {levelMeta} value.meta
   * @param {string} value.globalLightId
   */
  function open(value: var) {
    lightField.value = value.globalLightId;
    cameraPositionField.value = value.meta.camera.position;
    minBoundaryField.value = value.meta.boundaries.min;
    maxBoundaryField.value = value.meta.boundaries.max;
    inner.initialData = value;
    root.show();
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
      const validator = inner.createValidator();
      const validationResult = validator.validate({
        light: lightField.value,
        min: minBoundaryField.value,
        max: maxBoundaryField.value,
      });
      if (!validationResult.isValid()) {
        return;
      }

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
    valueRole: "id"
    textRole: "name"
    model: root.directionalLightsList
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

  QtObject {
    id: inner
    property var initialData

    function createValidator() {
      const light = new FV.StringValidator()
        .notEmpty({ message: qsTr("Can't be empty") })
        .on(WU.wrapInputErrors(lightField));
      const min = new FV.Vector3DValidator()
        .max(maxBoundaryField.value)
        .on(WU.wrapInputErrors(minBoundaryField))
      const max = new FV.Vector3DValidator()
        .min(minBoundaryField.value)
        .on(WU.wrapInputErrors(maxBoundaryField))
      return new FV.ObjectValidator({
        light,
        min,
        max,
      }).on(WU.createRootLogger());
    }
  }
}
