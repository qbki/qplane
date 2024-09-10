import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Item {
  property alias label: label.text
  property vector3d value
  property bool enabled: true

  id: root
  height: (label.height +
           layout.spacing +
           xField.height * 3 +
           axisFields.spacing * 2)

  onValueChanged: {
    internal.holdInputsUpdate = true;
    const vector = internal.vector3dToStrings(root.value);
    if (!xField.activeFocus) {
      xField.text = vector.x;
    }
    if (!yField.activeFocus) {
      yField.text = vector.y;
    }
    if (!zField.activeFocus) {
      zField.text = vector.z;
    }
    internal.holdInputsUpdate = false;
  }

  QtObject {
    id: internal
    property bool holdInputsUpdate: false
    property real axisLabelWidth: Theme.spacing(1)

    function stringToValidNumber(value: string): real {
      const num = Number.parseFloat(value);
      // Also: isFinite(NaN) returns false
      return Number.isFinite(num) ? num : 0;
    }

    function parseFields(): vector3d {
      return Qt.vector3d(
        internal.stringToValidNumber(xField.text),
        internal.stringToValidNumber(yField.text),
        internal.stringToValidNumber(zField.text)
      );
    }

    function assignWhenNew() {
      if (internal.holdInputsUpdate) {
        return;
      }
      const newValue = parseFields();
      if (!root.value.fuzzyEquals(newValue)) {
        root.value = newValue;
      }
    }

    // I try to avoid this kind of numbers: 0.4000000059604645.
    function vector3dToStrings(value: vector3d): var {
      const [x, y, z] = (/\((.*)\)/).exec(value)[1].split(", ");
      return { x, y, z };
    }

    function handleLoosingFocus(item: TextField, axis: string) {
      if (item.activeFocus) {
        return;
      }
      const vector = internal.vector3dToStrings(root.value);
      item.text = vector[axis];
    }
  }

  ColumnLayout {
    id: layout
    anchors.fill: parent

    Label {
      id: label
      Layout.fillWidth: false

      MouseArea {
        anchors.fill: parent
        onClicked: textField.forceActiveFocus()
      }
    }

    ColumnLayout {
      id: axisFields
      spacing: 1

      RowLayout {
        TextField {
          id: xField
          Layout.fillWidth: true
          onActiveFocusChanged: internal.handleLoosingFocus(xField, "x")
          onTextChanged: internal.assignWhenNew()
          enabled: root.enabled
        }

        Label {
          text: "X"
          Layout.preferredWidth: internal.axisLabelWidth
        }
      }

      RowLayout {
        TextField {
          id: yField
          Layout.fillWidth: true
          onActiveFocusChanged: internal.handleLoosingFocus(yField, "y")
          onTextChanged: internal.assignWhenNew()
          enabled: root.enabled
        }

        Label {
          text: "Y"
          Layout.preferredWidth: internal.axisLabelWidth
        }
      }

      RowLayout {
        TextField {
          id: zField
          Layout.fillWidth: true
          onActiveFocusChanged: internal.handleLoosingFocus(zField, "z")
          onTextChanged: internal.assignWhenNew()
          enabled: root.enabled
        }

        Label {
          text: "Z"
          Layout.preferredWidth: internal.axisLabelWidth
        }
      }
    }
  }
}
