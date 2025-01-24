pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Item {
  property alias label: input.label
  property real value: 0
  property alias errorMessage: errorMessage.text

  id: root
  implicitHeight: input.height + errorMessage.getAdaptiveHeight(inputLayout.spacing)

  onValueChanged: {
    if (Number.isNaN(root.value)) {
      return;
    }
    if (root.value !== Number.parseFloat(input.value)) {
      input.value = root.value;
    }
  }

  Component.onCompleted: {
    input.value = root.value;
  }

  ColumnLayout {
    id: inputLayout
    anchors.left: root.left
    anchors.right: root.right

    FormTextInput {
      id: input
      Layout.fillWidth: true
      onValueChanged: {
        const newValue = Number.parseFloat(input.value);
        if (root.value !== newValue) {
          root.value = newValue;
        }
      }
    }

    InputErrorMessage {
      id: errorMessage
    }
  }
}
