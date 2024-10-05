import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  signal canceled()
  signal accepted(newEntityModel: entityDirectionalLight, initialData: entityDirectionalLight)

  id: root
  title: qsTr("Edit a directional light")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityDirectionalLight) {
    idField.value = initialData.id;
    colorField.value = initialData.color;
    directionField.value = initialData.direction;
    internal.initialData = initialData;
    root.show();
  }

  QtObject {
    id: internal
    property entityDirectionalLight initialData
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
      const newEntityModel = EntityDirectionalLightFactory.create();
      newEntityModel.id = idField.value;
      newEntityModel.color = colorField.value;
      newEntityModel.direction = directionField.value;
      root.accepted(newEntityModel, internal.initialData);
      root.close();
    }
  }

  FormTextInput {
    id: idField
    label: qsTr("ID")
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
}
