import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  required property url modelsDir
  required property url projectDir
  required property list<entityModel> modelsList

  signal canceled()
  signal accepted(newEntityModel: entityModel, initialData: entityModel)

  id: root
  title: qsTr("Edit a model")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityModel) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    pathField.value = initialData.path;
    isOpaqueField.checkState = initialData.isOpaque ? Qt.Checked : Qt.Unchecked;
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
        name: nameField.value,
        path: pathField.value.toString(),
      });

      if (!validationResult.isValid()) {
        return;
      }

      const newEntity = EntityModelFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.path = pathField.value;
      newEntity.isOpaque = isOpaqueField.checkState === Qt.Checked;
      root.accepted(newEntity, inner.initialData);
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

  FormFilesComboBoxInput {
    id: pathField
    label: qsTr("Path to a *.glb model")
    folder: root.modelsDir
    rootFolder: root.projectDir
    extentions: [".glb"]
    Layout.fillWidth: true
    onValueChanged: {
      if (nameField.value === "" && !!pathField.value) {
        nameField.value = FileIO.fileName(pathField.value).replace(/.glb$/, "");
      }
    }
  }

  FormCheckBoxInput {
    id: isOpaqueField
    label: qsTr("Is a model opaque?")
  }

  QtObject {
    id: inner
    property entityModel initialData

    function createValidator() {
      const name = WU.createNameValidator(root.modelsList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));
      const path = new FV.StringValidator()
        .notEmpty({ message: qsTr("The value should't be empty") })
        .on(WU.wrapInputErrors(pathField));
      return new FV.ObjectValidator({ name, path })
        .on(WU.createRootLogger());
    }
  }
}
