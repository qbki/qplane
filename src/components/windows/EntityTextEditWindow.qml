import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app
import "../../jsutils/utils.mjs" as JS

EditWindowBase {
  required property url translationPath

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
    textIdField.value = (Boolean(foundTextIdPair) ? foundTextIdPair : inner.mapping[0]).key;

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

  FormTextInput {
    id: sizeField
    label: qsTr("Size (points)")
    Layout.fillWidth: true
  }

  FormColorInput {
    id: colorField
    label: qsTr("Color")
    Layout.fillWidth: true
  }

  FormNullableTextInput {
    id: widthField
    label: qsTr("Width")
    value: null
    Layout.fillWidth: true
  }

  FormNullableTextInput {
    id: heightField
    label: qsTr("Height")
    value: null
    Layout.fillWidth: true
  }

  QtObject {
    id: inner
    property entityText initialData
    property var mapping: {
      const result = [{ key: "", value: "" }];
      for (const [key, value] of Object.entries(translations.mapping)) {
        result.push({ key, value });
      }
      return result;
    }
  }

}
