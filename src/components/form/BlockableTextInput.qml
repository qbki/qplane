import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../jsutils/utils.mjs" as JS

Item {
  property string value: ""

  id: root
  height: input.height

  onValueChanged: {
    if (!JS.areStrsEqual(input.text, root.value)) {
      input.text = root.value;
    }
  }

  function switchToInput() {
    input.visible = true;
    button.visible = false;
    input.text = root.value;
    input.forceActiveFocus();
  }

  function switchToButton() {
    input.visible = false;
    button.visible = true;
    button.highlighted = false;
    button.down = false;
  }

  Button {
    id: button
    anchors.fill: parent

    contentItem: Label {
      text: root.value
      horizontalAlignment: Text.AlignLeft
    }

    onActiveFocusChanged: {
      root.switchToInput();
    }

    onPressed: {
      root.switchToInput();
    }

    Keys.onReturnPressed: {
      root.switchToInput();
    }
  }

  TextField {
    id: input
    anchors.left: parent.left
    anchors.right: parent.right
    visible: false

    onAccepted: {
      if (!JS.areStrsEqual(input.text, root.value)) {
        root.value = input.text;
      }
      nextItemInFocusChain().forceActiveFocus();
    }

    onActiveFocusChanged: {
      if (!input.activeFocus) {
        root.switchToButton();
      }
    }
  }
}
