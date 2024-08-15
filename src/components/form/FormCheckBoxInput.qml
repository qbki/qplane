import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Item {
  property alias label: labelComponent.text
  property alias checkState: checkBox.checkState

  height: Math.max(checkBox.height, labelComponent.height)

  RowLayout {

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
}
