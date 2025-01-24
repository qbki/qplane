import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/utils.mjs" as JS
import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  required property url soundsDir
  required property url projectDir
  property alias modelsList: projectileModelIdField.model
  required property list<entityWeapon> weaponsList

  signal canceled()
  signal accepted(newWeapon: entityWeapon, weapon: entityWeapon)

  id: root
  title: qsTr("Edit a weapon")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityWeapon) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    projectileModelIdField.value = initialData.projectileModelId;
    projectileSpeedField.value = initialData.projectileSpeed;
    fireRateField.value = initialData.fireRate;
    lifetimeField.value = initialData.lifetime;
    spreadField.value = initialData.spread;
    shotSoundPathField.value = initialData.shotSoundPath;
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
        fireRate: fireRateField.value,
        lifetime: lifetimeField.value,
        name: nameField.value,
        projectileModel: projectileModelIdField.value,
        projectileSpeed: projectileSpeedField.value,
        spread: spreadField.value,
      });
      if (!validationResult.isValid()) {
        return;
      }

      const newEntity = EntityWeaponFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.projectileModelId = projectileModelIdField.value;
      newEntity.projectileSpeed = JS.toFinitFloat(projectileSpeedField.value);
      newEntity.fireRate = JS.toFinitFloat(fireRateField.value);
      newEntity.lifetime = JS.toFinitFloat(lifetimeField.value);
      newEntity.spread = JS.toFinitFloat(spreadField.value);
      newEntity.shotSoundPath = shotSoundPathField.value;
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

  FormNumberInput {
    id: projectileSpeedField
    label: qsTr("Projectile speed (units per second)")
    Layout.fillWidth: true
  }

  FormNumberInput {
    id: fireRateField
    label: qsTr("Rate of fire (rounds per second)")
    Layout.fillWidth: true
  }

  FormNumberInput {
    id: lifetimeField
    label: qsTr("Projectile lifetime (seconds)")
    Layout.fillWidth: true
  }

  FormNumberInput {
    id: spreadField
    label: qsTr("Spread (radians)")
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: projectileModelIdField
    valueRole: "id"
    textRole: "name"
    label: qsTr("Projectile model")
    Layout.fillWidth: true
  }

  FormFilesComboBoxInput {
    id: shotSoundPathField
    label: qsTr("Shot sound (*.wav)")
    folder: root.soundsDir
    rootFolder: root.projectDir
    extentions: [".wav"]
    hasEmpty: true
    Layout.fillWidth: true
  }

  QtObject {
    id: inner
    property entityWeapon initialData

    function createValidator() {
      const name = WU.createNameValidator(root.weaponsList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));

      const modelEmptyMessage = qsTr("Can't be empty");
      const projectileModel = new FV.StringValidator({ message: modelEmptyMessage })
        .notEmpty({ message: modelEmptyMessage })
        .on(WU.wrapInputErrors(projectileModelIdField));

      const createNumValidator = () => new FV.NumberValidator().min(0).finite();
      const projectileSpeed = createNumValidator().on(WU.wrapInputErrors(projectileSpeedField));
      const fireRate = createNumValidator().on(WU.wrapInputErrors(fireRateField));
      const lifetime = createNumValidator().on(WU.wrapInputErrors(lifetimeField));
      const spread = createNumValidator().on(WU.wrapInputErrors(spreadField));

      return new FV.ObjectValidator({
        fireRate,
        lifetime,
        name,
        projectileModel,
        projectileSpeed,
        spread,
      }).on(WU.createRootLogger());
    }
  }
}
