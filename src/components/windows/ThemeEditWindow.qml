pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

EditWindowBase {
  required property url themePathUrl;
  required property url projectFolderUrl;

  id: root
  title: qsTr("Edit theme")
  cancelAction: cancelHandler
  acceptAction: acceptHandler

  function open() {
    try {
      if (FileIO.isExists(root.themePathUrl)) {
        const json = FileIO.loadJson(root.themePathUrl);
        fontField.value = FileIO.absolutePath(root.projectFolderUrl, json.font);
      }
    } catch(error) {
      console.error(error);
    }
    root.show();
  }

  Action {
    id: cancelHandler
    text: qsTr("Close")
    onTriggered: root.close()
  }

  Action {
    id: acceptHandler
    text: qsTr("Save and close")
    onTriggered: {
      try {
        const data = {
          font: FileIO.relativePath(root.projectFolderUrl, fontField.value),
        };
        FileIO.saveJson(root.themePathUrl, data);
        root.close();
      } catch(error) {
        console.error(error);
      }
    }
  }

  FormFilesComboBoxInput {
    id: fontField
    Layout.fillWidth: true
    label: qsTr("Path to the font")
    folder: root.projectFolderUrl
    rootFolder: root.projectFolderUrl
    hasEmpty: false
    extentions: [".ttf"]
  }
}
