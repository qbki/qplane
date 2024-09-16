import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  property url modelsDir
  property url projectDir

  signal canceled()
  signal accepted(newEntityModel: entityModel, initialData: entityModel)

  id: root
  title: qsTr("Edit a model")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityModel) {
    idField.value = initialData.id;
    pathField.value = initialData.path;
    isOpaqueField.checkState = initialData.is_opaque ? Qt.Checked : Qt.Unchecked;
    internal.initialData = initialData;
    root.show();
  }

  QtObject {
    id: internal
    property entityModel initialData
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
      const newEntityModel = EntityModelFactory.create();
      newEntityModel.id = idField.value;
      newEntityModel.path = pathField.value;
      newEntityModel.isOpaque = isOpaqueField.checkState === Qt.Checked;
      root.accepted(newEntityModel, internal.initialData);
      root.close();
    }
  }

  FormTextInput {
    id: idField
    label: qsTr("ID")
    Layout.fillWidth: true
  }

  FormFilesComboBoxInput {
    id: pathField
    label: qsTr("Path to a *.glb model")
    folder: modelsDir
    rootDir: projectDir
    Layout.fillWidth: true
    onValueChanged: {
      if (idField.value === "" && !!pathField.value) {
        idField.value = FileIO.fileName(pathField.value).replace(/.glb$/, "");
      }
    }
  }

  FormCheckBoxInput {
    id: isOpaqueField
    label: qsTr("Is a model opaque?")
  }
}
