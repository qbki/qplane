import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/formValidator.mjs" as FV
import "qrc:/jsutils/utils.mjs" as JS
import "./utils.mjs" as WU
import app

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
        lifetime: lifetimeField.value,
        model: modelIdField.value,
        name: nameField.value,
        quantity: quantityField.value,
        speed: speedField.value,
      });
      if (!validationResult.isValid()) {
        return;
      }

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

  FormNumberInput {
    id: lifetimeField
    label: qsTr("Lifetime (seconds)")
    Layout.fillWidth: true
  }

  FormNumberInput {
    id: speedField
    label: qsTr("Speed (units per second)")
    Layout.fillWidth: true
  }

  FormNumberInput {
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

  QtObject {
    id: inner
    property entityParticles initialData

    function createValidator() {
      const name = WU.createNameValidator(root.modelsList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));

      const modelEmptyMessage = qsTr("Can't be empty");
      const model = new FV.StringValidator({ message: modelEmptyMessage })
        .notEmpty({ message: modelEmptyMessage })
        .on(WU.wrapInputErrors(modelIdField));

      const createNumValidator = (min) => new FV.NumberValidator().min(0).finite();
      const lifetime = createNumValidator().on(WU.wrapInputErrors(lifetimeField));
      const speed = createNumValidator().on(WU.wrapInputErrors(speedField));
      const quantity = createNumValidator().on(WU.wrapInputErrors(quantityField));

      return new FV.ObjectValidator({
        lifetime,
        model,
        name,
        quantity,
        speed,
      }).on(WU.createRootLogger());
    }
  }
}
