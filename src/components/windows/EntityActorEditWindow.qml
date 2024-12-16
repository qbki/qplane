pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app
import "../../jsutils/utils.mjs" as JS

EditWindowBase {
  required property list<entityModel> modelsList
  required property list<entityWeapon> weaponsList
  required property list<entityParticles> particlesList

  signal canceled()
  signal accepted(newActor: entityActor, actor: entityActor)

  id: root
  title: qsTr("Edit an actor")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityActor) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    modelIdField.value = initialData.model_id;
    speedField.acceleration = initialData.speed.acceleration;
    speedField.damping = initialData.speed.damping;
    speedField.speed = initialData.speed.speed;
    livesField.value = initialData.lives;
    hitParticlesIdField.value = initialData.hit_particles_id;
    debrisModelIdField.value = initialData.debris_id;
    weaponIdField.value = initialData.weapon_id;
    inner.initialData = initialData;
    root.show();
  }

  QtObject {
    id: inner
    property entityActor initialData
    property list<entityModel> emptyableModelsList: [EntityModelFactory.create()].concat(root.modelsList)
    property list<entityWeapon> emptyableWeaponsList: [EntityWeaponFactory.create()].concat(root.weaponsList)
    property list<entityParticles> emptyableParticlesList: [EntityParticlesFactory.create()].concat(root.particlesList)
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
      const speed = EntityPropVelocityFactory.create();
      speed.acceleration = speedField.acceleration;
      speed.damping = speedField.damping;
      speed.speed = speedField.speed;

      const newEntity = EntityActorFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.model_id = modelIdField.value;
      newEntity.debris_id = debrisModelIdField.value;
      newEntity.weapon_id = weaponIdField.value;
      newEntity.hit_particles_id = hitParticlesIdField.value;
      newEntity.speed = speed;
      newEntity.lives = JS.toFinitInt(livesField.value);

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

  FormVelocityInput {
    id: speedField
    Layout.fillWidth: true
    acceleration: null
    damping: null
    speed: null
  }

  FormTextInput {
    id: livesField
    label: qsTr("Lives")
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: modelIdField
    label: qsTr("Model")
    valueRole: "id"
    textRole: "name"
    model: root.modelsList
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: hitParticlesIdField
    label: qsTr("Hit particles")
    valueRole: "id"
    textRole: "name"
    model: inner.emptyableParticlesList
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: weaponIdField
    label: qsTr("Weapon")
    valueRole: "id"
    textRole: "name"
    model: inner.emptyableWeaponsList
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: debrisModelIdField
    label: qsTr("Debris")
    valueRole: "id"
    textRole: "name"
    model: inner.emptyableModelsList
    Layout.fillWidth: true
  }
}
