import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  property list<entityDirectionalLight> directionalLightsList: []

  signal canceled()
  signal accepted(newEntityModel: entityDirectionalLight, initialData: entityDirectionalLight)

  id: root
  title: qsTr("Edit a directional light")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityDirectionalLight) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    colorField.value = initialData.color;
    directionField.value = initialData.direction;
    inner.initialData = initialData;
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
        color: colorField.value,
        direction: directionField.value,
        name: nameField.value,
      });
      if (!validationResult.isValid()) {
        return;
      }

      const newEntityModel = EntityDirectionalLightFactory.create();
      newEntityModel.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntityModel.name = nameField.value;
      newEntityModel.color = colorField.value;
      newEntityModel.direction = directionField.value;
      root.accepted(newEntityModel, inner.initialData);
      root.close();
    }
  }

  UuidGenerator {
    id: uuid
  }

  FormInfoLabel {
    id: idField
    label: qsTr("ID")
    Layout.fillWidth: true
    visible: Boolean(idField.value)
  }

  FormTextInput {
    id: nameField
    label: qsTr("Name")
    Layout.fillWidth: true
  }

  FormVector3DInput {
    id: directionField
    label: qsTr("Direction")
    Layout.fillWidth: true
  }

  FormColorInput {
    id: colorField
    label: qsTr("Color")
    Layout.fillWidth: true
  }

  QtObject {
    id: inner
    property entityDirectionalLight initialData

    function createValidator() {
      const name = WU.createNameValidator(root.directionalLightsList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));
      const direction = new FV.Vector3DValidator()
        .notZero()
        .on(WU.wrapInputErrors(directionField));
      const color = new FV.ColorValidator()
        .on(WU.wrapInputErrors(colorField));
      return new FV.ObjectValidator({
        color,
        direction,
        name,
      }).on(WU.createRootLogger());
    }
  }
}
