import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Window {
  default property alias data: contentLayout.data

  required property Action cancelAction
  required property Action acceptAction

  id: root
  modality: Qt.WindowModal
  minimumWidth: 640
  minimumHeight: 480

  Pane {
    anchors.fill: parent
  }

  ScrollView {
    anchors.fill: parent
    contentHeight: {
      const layoutHeight = layout.implicitHeight + layout.anchors.margins * 2;
      const parentHeight = parent.height;
      return Math.max(layoutHeight, parentHeight);
    }
    clip: true

    ColumnLayout {
      id: layout
      anchors.fill: parent
      anchors.margins: Theme.spacing(2)
      spacing: Theme.spacing(3)

      ColumnLayout {
        id: contentLayout
        Layout.fillWidth: true
        spacing: Theme.spacing(3)
      }

      ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 0

        Item {
          Layout.fillHeight: true
        }

        FormAcceptButtonsGroup {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignBottom
          cancelAction: root.cancelAction
          acceptAction: root.acceptAction
        }
      }
    }
  }
}
