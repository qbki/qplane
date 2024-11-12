import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app
import "../../jsutils/utils.mjs" as JS

Item {
  property alias label: label.text
  property vector3d value: Qt.vector3d(0, 0, 0)
  property bool enabled: true

  id: root
  height: (label.height +
           layout.spacing +
           xField.height * 3 +
           axisFields.spacing * 2)

  onValueChanged: {
    internal.holdInputsUpdate = true;
    const vector = internal.vector3dToStrings(root.value);
    if (!JS.areStrsEqual(xField.value, vector.x)) {
      xField.value = vector.x;
    }
    if (!JS.areStrsEqual(yField.value, vector.y)) {
      yField.value = vector.y;
    }
    if (!JS.areStrsEqual(zField.value, vector.z)) {
      zField.value = vector.z;
    }
    internal.holdInputsUpdate = false;
  }

  QtObject {
    id: internal
    property bool holdInputsUpdate: false
    property real axisLabelWidth: Theme.spacing(1)

    function parseFields(): vector3d {
      return Qt.vector3d(
        JS.stringToValidNumber(xField.value),
        JS.stringToValidNumber(yField.value),
        JS.stringToValidNumber(zField.value)
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
        onClicked: xField.forceActiveFocus()
      }
    }

    ColumnLayout {
      id: axisFields
      spacing: 0

      RowLayout {
        BlockableTextInput {
          id: xField
          Layout.fillWidth: true
          onActiveFocusChanged: internal.handleLoosingFocus(xField, "x")
          onValueChanged: internal.assignWhenNew()
          enabled: root.enabled
        }

        Label {
          text: "X"
          Layout.preferredWidth: internal.axisLabelWidth
        }
      }

      RowLayout {
        BlockableTextInput {
          id: yField
          Layout.fillWidth: true
          onActiveFocusChanged: internal.handleLoosingFocus(yField, "y")
          onValueChanged: internal.assignWhenNew()
          enabled: root.enabled
        }

        Label {
          text: "Y"
          Layout.preferredWidth: internal.axisLabelWidth
        }
      }

      RowLayout {
        BlockableTextInput {
          id: zField
          Layout.fillWidth: true
          onActiveFocusChanged: internal.handleLoosingFocus(zField, "z")
          onValueChanged: internal.assignWhenNew()
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
