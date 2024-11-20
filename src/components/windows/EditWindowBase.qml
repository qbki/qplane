import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Window {
  default property alias data: contentLayout.data

  required property Action cancelAction
  required property Action acceptAction
  property bool expand: true

  id: root
  modality: Qt.ApplicationModal
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
        Layout.fillHeight: root.expand
        Layout.fillWidth: true
        spacing: 0

        Item {
          Layout.fillHeight: root.expand
        }

        FormAcceptButtonsGroup {
          Layout.fillWidth: true
          cancelAction: root.cancelAction
          acceptAction: root.acceptAction
        }
      }
    }
  }
}
