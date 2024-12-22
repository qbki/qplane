import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app
import "../../jsutils/utils.mjs" as JS

EditWindowBase {
  property alias modelsList: modelIdField.model

  signal canceled()
  signal accepted(newParticles: entityParticles, particles: entityParticles)

  id: root
  title: qsTr("Edit particles")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: entityParticles) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
    lifetimeField.value = initialData.lifetime;
    speedField.value = initialData.speed;
    quantityField.value = initialData.quantity;
    modelIdField.value = initialData.modelId;
    inner.initialData = initialData;
    root.show();
  }

  QtObject {
    id: inner
    property entityParticles initialData
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
      const newEntity = EntityParticlesFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
      newEntity.lifetime = JS.toFinitFloat(lifetimeField.value);
      newEntity.speed = JS.toFinitFloat(speedField.value);
      newEntity.quantity = JS.toFinitInt(quantityField.value);
      newEntity.modelId = modelIdField.value;
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
    id: lifetimeField
    label: qsTr("Lifetime (seconds)")
    Layout.fillWidth: true
  }

  FormTextInput {
    id: speedField
    label: qsTr("Speed (units per second)")
    Layout.fillWidth: true
  }

  FormTextInput {
    id: quantityField
    label: qsTr("Quantity")
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
}
