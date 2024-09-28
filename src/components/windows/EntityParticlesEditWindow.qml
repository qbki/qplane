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
    lifetimeField.value = initialData.lifetime;
    speedField.value = initialData.speed;
    quantityField.value = initialData.quantity;
    modelIdField.value = initialData.model_id;
    internal.initialData = initialData;
    root.show();
  }

  QtObject {
    id: internal
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
      newEntity.id = idField.value;
      newEntity.lifetime = JS.toFinitFloat(lifetimeField.value);
      newEntity.speed = JS.toFinitFloat(speedField.value);
      newEntity.quantity = JS.toFinitInt(quantityField.value);
      newEntity.model_id = modelIdField.value;
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
    model: root.modelsList
    Layout.fillWidth: true
  }
}
