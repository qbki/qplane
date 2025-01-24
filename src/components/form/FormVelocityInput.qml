pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "qrc:/jsutils/formValidator.mjs" as FV
import app

Rectangle {
  property alias acceleration: accelerationField.value
  property alias damping: dampingField.value
  property alias speed: speedField.value

  implicitHeight: (accelerationField.height +
                   dampingField.height +
                   speedField.height +
                   + layout.spacing * 2
                   + layout.anchors.topMargin + layout.anchors.bottomMargin)
  border.color: palette.button
  color: "transparent"

  function getValidator() {
    const factory = (field) => {
      return new FV
        .OrValidator(
          new FV.NullValidator({ message: "The value could be empty" }),
          new FV.NumberValidator().min(0).finite(),
        )
        .on({
          reset: () => field.errorMessage = "",
          failure: (errors) => field.errorMessage = errors.join(`\n${inner.orText} `),
        });
    };

    return new FV.ObjectValidator({
      acceleration: factory(accelerationField),
      damping: factory(dampingField),
      speed: factory(speedField),
    });
  }

  function getValues() {
    return {
      acceleration: accelerationField.value,
      damping: dampingField.value,
      speed: speedField.value,
    };
  }

  SystemPalette {
    id: palette
  }

  ColumnLayout {
    id: layout
    anchors.fill: parent
    anchors.margins: Theme.spacing(1)

    FormNullableNumberInput {
      id: accelerationField
      label: qsTr("Acceleration")
      value: null
      Layout.fillWidth: true
    }

    FormNullableNumberInput {
      id: dampingField
      label: qsTr("Damping")
      value: null
      Layout.fillWidth: true
    }

    FormNullableNumberInput {
      id: speedField
      label: qsTr("Speed")
      value: null
      Layout.fillWidth: true
    }
  }

  QtObject {
    property string orText: qsTr("or")
    id: inner
  }
}
