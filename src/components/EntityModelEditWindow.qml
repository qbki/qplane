import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.platform as Platform

import app

Window {
  property url modelsDir
  property url projectDir

  QtObject {
    id: store
    property entityModel initialData
  }

  signal canceled()
  signal accepted(newEntityModel: entityModel, initialData: entityModel)

  id: root
  title: qsTr("Edit a model")
  modality: Qt.WindowModal
  minimumWidth: 640
  minimumHeight: 480

  function open(initialData: entityModel) {
    idField.value = initialData.id;
    pathField.value = initialData.path;
    isOpaqueField.checkState = initialData.is_opaque ? Qt.Checked : Qt.Unchecked;
    store.initialData = initialData;
    root.show();
  }

  Action {
    id: cancelAction
    text: qsTr("Cancel")
    onTriggered: {
      root.canceled();
      root.close();
    }
  }

  Action {
    id: acceptAction
    text: qsTr("Ok")
    onTriggered: {
      const newEntityModel = EntityModelFactory.create();
      newEntityModel.id = idField.value;
      newEntityModel.path = pathField.value;
      newEntityModel.isOpaque = isOpaqueField.checkState === Qt.Checked;
      root.accepted(newEntityModel, store.initialData);
      root.close();
    }
  }

  Pane {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Theme.spacing(1)
      spacing: Theme.spacing(3)

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

      Item {
        Layout.fillHeight: true
      }

      FormAcceptButtonsGroup {
        Layout.fillWidth: true
        cancelAction: cancelAction
        acceptAction: acceptAction
      }
    }
  }
}
