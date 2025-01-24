import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/utils.mjs" as JS
import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  required property url translationPath
  property list<entityText> textsList: []

  signal canceled()
  signal accepted(newWeapon: entityText, weapon: entityText)

  id: root
  title: qsTr("Edit a text")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityText) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    sizeField.value = initialData.size;
    colorField.value = initialData.color;
    widthField.value = initialData.width;
    heightField.value = initialData.height;

    const foundTextIdPair = inner.mapping.find(({ key }) => key === initialData.textId);
    if (foundTextIdPair) {
      textIdField.value = foundTextIdPair;
    }

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
        height: heightField.value,
        name: nameField.value,
        size: sizeField.value,
        textId: textIdField.value,
        width: widthField.value,
      });
      if (!validationResult.isValid()) {
        return;
      }

      const newEntity = EntityTextFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.textId = textIdField.value;
      newEntity.size = JS.toFinitFloat(sizeField.value);
      newEntity.color = colorField.value;
      newEntity.width = widthField.value === null ? null : JS.toFinitFloat(widthField.value);
      newEntity.height = heightField.value === null ? null : JS.toFinitFloat(heightField.value);
      root.accepted(newEntity, inner.initialData);
      root.close();
    }
  }

  UuidGenerator {
    id: uuid
  }

  Translations {
    id: translations
    file: root.translationPath
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

  FormComboBoxInput {
    id: textIdField
    label: qsTr("Text")
    textRole: "value"
    valueRole: "key"
    Layout.fillWidth: true
    model: inner.mapping
  }

  FormNumberInput {
    id: sizeField
    label: qsTr("Size (points)")
    Layout.fillWidth: true
  }

  FormColorInput {
    id: colorField
    label: qsTr("Color")
    Layout.fillWidth: true
  }

  FormNullableNumberInput {
    id: widthField
    label: qsTr("Width")
    value: null
    Layout.fillWidth: true
  }

  FormNullableNumberInput {
    id: heightField
    label: qsTr("Height")
    value: null
    Layout.fillWidth: true
  }

  QtObject {
    id: inner
    property entityText initialData

    property var mapping: (Object.entries(translations.mapping)
                                 .map(([key, value]) => ({ key, value })))

    function createValidator() {
      const name = WU.createNameValidator(root.textsList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));
      const textId = new FV.StringValidator({ wrongTypeMessage: qsTr("Can't be empty") })
        .on(WU.wrapInputErrors(textIdField));
      const color = new FV.ColorValidator()
        .on(WU.wrapInputErrors(colorField));
      const size = new FV.NumberValidator()
        .integer()
        .finite()
        .min(1)
        .on(WU.wrapInputErrors(sizeField));

      const couldBeEmptyMessage = qsTr("The value could be empty");
      const width = new FV
        .OrValidator(
          new FV.NullValidator({ message: couldBeEmptyMessage }),
          new FV.NumberValidator().min(0).finite(),
        )
        .on(WU.wrapInputErrors(widthField));
      const height = new FV
        .OrValidator(
          new FV.NullValidator({ message: couldBeEmptyMessage }),
          new FV.NumberValidator().min(0).finite(),
        )
        .on(WU.wrapInputErrors(heightField));

      return new FV.ObjectValidator({
        color,
        height,
        name,
        size,
        textId,
        width,
      }).on(WU.createRootLogger());
    }
  }
}
