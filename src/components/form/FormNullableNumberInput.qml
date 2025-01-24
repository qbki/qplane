pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "qrc:/jsutils/utils.mjs" as JS

Item {
  property alias label: input.label
  /** @prop {null | number} */
  required property var value
  property alias errorMessage: input.errorMessage

  id: root
  implicitHeight: input.height

  onValueChanged: {
    if ((root.value === null) && (input.value !== "")) {
      input.value = "";
      return;
    }
    if (Number.isNaN(root.value)) {
      return;
    }
    if (JS.isNumber(root.value) && (root.value !== Number.parseFloat(input.value))) {
      input.value = root.value;
      return;
    }
  }

  ColumnLayout {
    id: inputLayout
    anchors.left: root.left
    anchors.right: root.right

    FormTextInput {
      id: input
      Layout.fillWidth: true
      onValueChanged: {
        if ((input.value === "") && (root.value !== null)) {
          root.value = null;
          return;
        }
        const newValue = Number.parseFloat(input.value);
        if (root.value !== newValue) {
          root.value = newValue;
        }
      }
    }
  }
}
