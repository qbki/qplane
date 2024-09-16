import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  required property var modelsList

  signal canceled()
  signal accepted(newActor: entityActor, actor: entityActor)

  id: root
  title: qsTr("Edit an actor")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityActor) {
    idField.value = initialData.id;
    modelIdField.value = initialData.model_id;
    speedField.value = initialData.speed;
    livesField.value = initialData.lives;
    hitParticlesIdField.value = initialData.hit_particles_id;
    debrisModelIdField.value = initialData.debris_id;
    internal.initialData = initialData;
    root.show();
  }

  QtObject {
    id: internal

    property entityActor initialData
    property var emptyableModelsList: [""].concat(root.modelsList)
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
      const newEntity = EntityActorFactory.create();

      newEntity.id = idField.value;
      newEntity.model_id = modelIdField.value;
      newEntity.debris_id = debrisModelIdField.value;
      newEntity.hit_particles_id = hitParticlesIdField.value;

      const speed = Number.parseFloat(speedField.value);
      newEntity.speed = Number.isFinite(speed) ? speed : 0;

      const lives = Number.parseInt(livesField.value);
      newEntity.lives = Number.isFinite(lives) ? lives : 0;

      root.accepted(newEntity, internal.initialData);
      root.close();
    }
  }

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

  FormTextInput {
    id: livesField
    label: qsTr("Lives")
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: modelIdField
    label: qsTr("Model")
    model: root.modelsList
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: hitParticlesIdField
    label: qsTr("Hit particles")
    model: internal.emptyableModelsList
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: debrisModelIdField
    label: qsTr("Debris")
    model: internal.emptyableModelsList
    Layout.fillWidth: true
  }
}
