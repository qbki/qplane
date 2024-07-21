import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
  property alias label: labelComponent.text
  property alias checkState: checkBox.checkState

  CheckBox {
    id: checkBox
    leftPadding: 8
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
