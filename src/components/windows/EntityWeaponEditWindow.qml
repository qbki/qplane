import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app
import "../../jsutils/utils.mjs" as JS

EditWindowBase {
  required property url soundsDir
  required property url projectDir
  property alias modelsList: projectileModelIdField.model

  signal canceled()
  signal accepted(newWeapon: entityWeapon, weapon: entityWeapon)

  id: root
  title: qsTr("Edit a weapon")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityWeapon) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    projectileModelIdField.value = initialData.projectile_model_id;
    projectileSpeedField.value = initialData.projectile_speed;
    fireRateField.value = initialData.fire_rate;
    lifetimeField.value = initialData.lifetime;
    spreadField.value = initialData.spread;
    shotSoundPathField.value = initialData.shot_sound_path;
    inner.initialData = initialData;
    root.show();
  }

  QtObject {
    id: inner
    property entityWeapon initialData
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
      const newEntity = EntityWeaponFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.projectile_model_id = projectileModelIdField.value;
      newEntity.projectile_speed = JS.toFinitFloat(projectileSpeedField.value);
      newEntity.fire_rate = JS.toFinitFloat(fireRateField.value);
      newEntity.lifetime = JS.toFinitFloat(lifetimeField.value);
      newEntity.spread = JS.toFinitFloat(spreadField.value);
      newEntity.shot_sound_path = shotSoundPathField.value;
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

  FormTextInput {
    id: projectileSpeedField
    label: qsTr("Projectile speed (units per second)")
    Layout.fillWidth: true
  }

  FormTextInput {
    id: fireRateField
    label: qsTr("Rate of fire (rounds per second)")
    Layout.fillWidth: true
  }

  FormTextInput {
    id: lifetimeField
    label: qsTr("Projectile lifetime (seconds)")
    Layout.fillWidth: true
  }

  FormTextInput {
    id: spreadField
    label: qsTr("Spread (radians)")
    Layout.fillWidth: true
  }

  FormComboBoxInput {
    id: projectileModelIdField
    label: qsTr("Projectile model")
    Layout.fillWidth: true
  }

  FormFilesComboBoxInput {
    id: shotSoundPathField
    label: qsTr("Shot sound (*.wav)")
    folder: root.soundsDir
    rootFolder: root.projectDir
    extentions: [".wav"]
    Layout.fillWidth: true
  }
}
