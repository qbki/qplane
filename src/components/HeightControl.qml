import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

OpacityHover {
  property real value: 0

  signal clickedUp(MouseEvent event)
  signal clickedDown(MouseEvent event)

  id: root
  height: content.height
  width: content.width
  layer.samples: 4

  SystemPalette {
    id: palette
  }

  ColumnLayout {
    id: content

    IconButton {
      id: buttonUp
      Layout.preferredWidth: 30
      Layout.preferredHeight: 30
      icon: UpIcon {}
    }

    Text {
      Layout.fillWidth: true
      text: root.value
      color: "#ffffff"
      style: Text.Outline
      styleColor: "#000000"
      horizontalAlignment: Qt.AlignHCenter
      verticalAlignment: Qt.AlignVCenter
      font.pointSize: 16
    }

    IconButton {
      id: buttonDown
      Layout.preferredWidth: 30
      Layout.preferredHeight: 30
      icon: DownIcon {}
    }
  }

  Component.onCompleted: {
    buttonUp.clicked.connect(root.clickedUp);
    buttonDown.clicked.connect(root.clickedDown);
  }
}
