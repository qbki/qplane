pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS

Item {
  property alias label: input.label
  required property var value

  function isActive() {
    return JS.isNotNil(root.value);
  }

  id: root
  height: input.height

  onValueChanged: {
    const isValueChanged = JS.stringToValidNumber(input.value) !== root.value;
    if (root.isActive() && isValueChanged) {
      input.value = root.value;
    }
  }

  RowLayout {
    anchors.fill: parent

    CheckBox {
      id: checkBox
      Layout.preferredWidth: 50
      checkState: root.isActive() ? Qt.Checked : Qt.Unchecked
      nextCheckState: function() {
        return checkBox.checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked;
      }
      onCheckStateChanged: {
        if (checkBox.checkState === Qt.Checked) {
          if (!root.isActive()) {
            root.value = 0;
          }
          if (input.value !== root.value) {
            input.value = root.value;
          }
        } else {
          root.value = null;
        }
      }
    }

    ColumnLayout {
      visible: !root.isActive()
      Layout.fillWidth: true
      Layout.fillHeight: true
      Label {
        text: root.label
        Layout.fillWidth: true
      }
      Label {
        text: qsTr("Unused")
        Layout.fillWidth: true
      }
    }

    FormTextInput {
      id: input
      visible: root.isActive()
      Layout.fillWidth: true
      onValueChanged: {
        if (root.isActive()) {
          const newValue = JS.stringToValidNumber(input.value);
          if (root.value !== newValue ) {
            root.value = newValue;
          }
        }
      }
    }
  }
}
