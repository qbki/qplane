import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Window {
  property alias modelsList: modelIdField.model

  QtObject {
    id: store
    property entityActor initialData
  }

  signal canceled()
  signal accepted(newActor: entityActor, actor: entityActor)

  id: root
  title: qsTr("Edit an actor")
  modality: Qt.WindowModal
  minimumWidth: 640
  minimumHeight: 480

  function open(initialData: entityActor) {
    idField.value = initialData.id;
    modelIdField.value = initialData.model_id;
    speedField.value = initialData.speed;
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
      const newEntity = EntityActorFactory.create();

      newEntity.id = idField.value;
      newEntity.model_id = modelIdField.value;

      const speed = Number.parseFloat(speedField.value);
      newEntity.speed = Number.isNaN(speed) ? 0 : speed;

      root.accepted(newEntity, store.initialData);
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
        id: speedField
        label: qsTr("Speed")
        Layout.fillWidth: true
      }

      FormComboBoxInput {
        id: modelIdField
        label: qsTr("Model")
        Layout.fillWidth: true
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
