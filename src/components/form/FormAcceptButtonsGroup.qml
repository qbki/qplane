import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Item {
  property alias acceptText: acceptButton.text
  property alias cancelText: cancelButton.text

  property alias acceptAction: acceptButton.action
  property alias cancelAction: cancelButton.action

  signal accept
  signal cancel

  id: root
  height: acceptButton.height

  RowLayout {
    id: layout
    anchors.fill: parent
    spacing: Theme.spacing(1)
    uniformCellSizes: false

    Item {
      Layout.fillWidth: true
    }

    Button {
      id: cancelButton
    }

    Button {
      id: acceptButton
    }

    Component.onCompleted: {
      acceptButton.clicked.connect(root.accept);
      cancelButton.clicked.connect(root.cancel);
    }
  }
}
