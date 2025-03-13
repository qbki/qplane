pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/utils.mjs" as JS
import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  required property list<entityActor> actorsList
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
    modelIdField.value = initialData.modelId;
    velocityFields.acceleration = initialData.speed.acceleration;
    velocityFields.damping = initialData.speed.damping;
    velocityFields.speed = initialData.speed.speed;
    rotationSpeedField.value = initialData.rotationSpeed;
    livesField.value = initialData.lives;
    hitParticlesIdField.value = initialData.hitParticlesId;
    debrisModelIdField.value = initialData.debrisId;
    weaponIdField.value = initialData.weaponId;
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
        lives: livesField.value,
        model: modelIdField.value,
        name: nameField.value,
        speed: velocityFields.getValues(),
        rotationSpeed: rotationSpeedField.value,
      });
      if (!validationResult.isValid()) {
        return;
      }

      const speed = EntityPropVelocityFactory.create();
      speed.acceleration = velocityFields.acceleration;
      speed.damping = velocityFields.damping;
      speed.speed = velocityFields.speed;

      const newEntity = EntityActorFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.modelId = modelIdField.value;
      newEntity.debrisId = debrisModelIdField.value;
      newEntity.weaponId = weaponIdField.value;
      newEntity.hitParticlesId = hitParticlesIdField.value;
      newEntity.speed = speed;
      newEntity.rotationSpeed = rotationSpeedField.value;
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
    id: velocityFields
    Layout.fillWidth: true
    acceleration: null
    damping: null
    speed: null
  }

  FormNumberInput {
    id: rotationSpeedField
    label: qsTr("Rotation speed (radians per second)")
    Layout.fillWidth: true
  }

  FormNumberInput {
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

  QtObject {
    id: inner
    property entityActor initialData
    property list<entityModel> emptyableModelsList: [EntityModelFactory.create()].concat(root.modelsList)
    property list<entityWeapon> emptyableWeaponsList: [EntityWeaponFactory.create()].concat(root.weaponsList)
    property list<entityParticles> emptyableParticlesList: [EntityParticlesFactory.create()].concat(root.particlesList)

    function createValidator() {
      const modelEmptyMessage = qsTr("Can't be empty");
      const model = new FV.StringValidator({ message: modelEmptyMessage })
        .notEmpty({ message: modelEmptyMessage })
        .on(WU.wrapInputErrors(modelIdField));

      const name = WU.createNameValidator(root.actorsList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));

      const lives = new FV.NumberValidator()
        .min(1)
        .finite()
        .integer()
        .on(WU.wrapInputErrors(livesField));

      const speed = velocityFields.getValidator();

      const rotationSpeed = new FV.NumberValidator()
        .min(0)
        .finite()
        .on(WU.wrapInputErrors(rotationSpeedField));

      return new FV.ObjectValidator({
        lives,
        model,
        name,
        rotationSpeed,
        speed,
      }).on(WU.createRootLogger());
    }
  }
}
