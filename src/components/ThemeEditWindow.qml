import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

Window {
  required property url themePathUrl;
  required property url projectFolderUrl;

  id: root
  title: qsTr("Edit theme")
  modality: Qt.WindowModal
  minimumWidth: 640
  minimumHeight: 480

  function open() {
    try {
      if (FileIO.isExists(root.themePathUrl)) {
        const json = FileIO.loadJson(root.themePathUrl);
        const absoluteFontPath = FileIO.absolutePath(root.projectFolderUrl, json.font);
        fontField.text = FileIO.toLocalFile(absoluteFontPath);
      }
    } catch(error) {
      console.error(error);
    }
    root.show();
  }

  Action {
    id: closeAction
    text: qsTr("Close")
    onTriggered: root.close()
  }

  Action {
    id: saveAndCloseAction
    text: qsTr("Save and close")
    onTriggered: {
      try {
        const data = {
          font: FileIO.relativePath(projectFolderUrl, FileIO.fromLocalFile(fontField.text)),
        };
        FileIO.saveJson(root.themePathUrl, data);
        root.close();
      } catch(error) {
        console.error(error);
      }
    }
  }

  Pane {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Theme.spacing(1)

      FormTextInput {
        id: fontField
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        label: qsTr("Path to the font")
      }

      Item {
        Layout.fillHeight: true
      }

      FormAcceptButtonsGroup {
        id: test
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignBottom
        acceptAction: saveAndCloseAction
        cancelAction: closeAction
      }
    }
  }
}
