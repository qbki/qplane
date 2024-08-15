import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.platform as Platform

import app

Window {
  property url modelsDir

  Item {
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
    idField.text = initialData.id;
    pathField.text = initialData.path;
    isOpaqueField.checkState = initialData.isOpaque ? Qt.Checked : Qt.Unchecked;
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
      newEntityModel.id = idField.text;
      newEntityModel.path = pathField.text;
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

      FormTextInput {
        id: pathField
        label: qsTr("Path to a *.glb model")
        Layout.fillWidth: true
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

  Platform.FileDialog {
    id: fileDilog
    title: qsTr("A 3D model selection")
    folder: modelsDir
    nameFilters: [ qsTr("glTF (*.glb)") ]
    onAccepted: {
      appState.projectDir = folder;
      if (appState.isModelsDirExists) {
        modelEntityState.populateFromDir(appState.modelsDir);
      } else {
        console.error("\"models\" directory doesn't exists");
      }
    }
  }
}
