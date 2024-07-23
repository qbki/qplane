import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

RowLayout {
  property alias label: labelComponent.text
  property alias checkState: checkBox.checkState

  CheckBox {
    id: checkBox
    leftPadding: Theme.spacing(1)
    rightPadding: 0
  }

  Label {
    id: labelComponent

    MouseArea {
      anchors.fill: parent
      onClicked: {
        checkBox.checked = !checkBox.checked
        checkBox.forceActiveFocus()
      }
    }
  }
}
