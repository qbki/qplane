import QtQuick
import QtQuick.Controls

Label {
  required property var model
  property var modelData: model.display

  signal leftMouseClick()
  signal rightMouseClick()

  id: root
  font.pointSize: 16
  text: modelData.id

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onClicked: function(event) {
      if (event.button === Qt.LeftButton) {
        root.leftMouseClick();
      } else if (event.button === Qt.RightButton) {
        root.rightMouseClick();
      }
    }
  }
}
