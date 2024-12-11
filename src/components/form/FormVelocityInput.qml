pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

Rectangle {
  property alias acceleration: accelerationField.value
  property alias damping: dampingField.value
  property alias speed: speedField.value

  implicitHeight: accelerationField.height * 3 + layout.spacing * 2 + layout.anchors.margins * 2
  border.color: palette.button
  color: "transparent"

  SystemPalette {
    id: palette
  }

  ColumnLayout {
    id: layout
    anchors.fill: parent
    anchors.margins: Theme.spacing(1)

    FormNullableTextInput {
      id: accelerationField
      label: qsTr("Acceleration")
      value: null
      Layout.fillWidth: true
    }

    FormNullableTextInput {
      id: dampingField
      label: qsTr("Damping")
      value: null
      Layout.fillWidth: true
    }

    FormNullableTextInput {
      id: speedField
      label: qsTr("Speed")
      value: null
      Layout.fillWidth: true
    }
  }
}
