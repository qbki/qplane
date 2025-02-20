pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Label {
  required property var model
  property var modelData: model.data

  signal leftMouseClick()
  signal rightMouseClick()

  id: root
  font.pointSize: 16
  text: modelData.name
  clip: true
  elide: Text.ElideRight

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
