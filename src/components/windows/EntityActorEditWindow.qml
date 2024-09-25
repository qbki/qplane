import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app
import "../../jsutils/utils.mjs" as JS

EditWindowBase {
  required property list<string> modelsList
  required property list<string> weaponsList

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
    weaponIdField.value = initialData.weapon_id;
    internal.initialData = initialData;
    root.show();
  }

  QtObject {
    id: internal
    property entityActor initialData
    property list<string> emptyableModelsList: [""].concat(root.modelsList)
    property list<string> emptyableWeaponsList: [""].concat(root.weaponsList)
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
      newEntity.weapon_id = weaponIdField.value;
      newEntity.hit_particles_id = hitParticlesIdField.value;
      newEntity.speed = JS.toFinitFloat(speedField.value);
      newEntity.lives = JS.toFinitInt(livesField.value);
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
    id: weaponIdField
    label: qsTr("Weapon")
    model: internal.emptyableWeaponsList
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: debrisModelIdField
    label: qsTr("Debris")
    model: internal.emptyableModelsList
    Layout.fillWidth: true
  }
}
