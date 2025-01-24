pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/jsutils/formValidator.mjs" as FV
import "./utils.mjs" as WU
import app

EditWindowBase {
  property list<levelLayer> layersList: []

  signal canceled()
  signal accepted(newWeapon: levelLayer, weapon: levelLayer)

  id: root
  title: qsTr("Edit layer name")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open(initialData: levelLayer) {
    idField.value = initialData.id;
    nameField.value = initialData.name;
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
      const validationResult = validator.validate({ name: nameField.value });
      if (!validationResult.isValid()) {
        return;
      }

      const newEntity = LevelLayerFactory.create();
      newEntity.id = uuid.generateIfEmpty(inner.initialData.id);
      newEntity.name = nameField.value;
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

  QtObject {
    id: inner
    property levelLayer initialData

    function createValidator() {
      const name = WU.createNameValidator(root.layersList, inner.initialData.name)
        .on(WU.wrapInputErrors(nameField));
      return new FV.ObjectValidator({ name }).on(WU.createRootLogger());
    }
  }
}
