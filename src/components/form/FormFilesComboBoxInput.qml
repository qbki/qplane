import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel as Platform

import "../../jsutils/utils.mjs" as JS
import app

Item {
  required property url rootDir;
  property alias folder: folderModel.folder;
  property alias label: label.text
  property alias nameFilters: folderModel.nameFilters;
  property url value;

  QtObject {
    id: internal
    property string role: "fileUrl"
  }

  id: root
  height: label.height + comboBox.height

  Platform.FolderListModel {
    id: folderModel
    showDirs: false
  }

  TransformModel {
    id: outputModel
    sourceModel: folderModel
    role: "filePath"
    map: function(value, role) {
      return JS.areStrsEqual(role.toString(), internal.role)
        ? FileIO.relativePath(root.rootDir, value)
        : value;
    }
  }

  ColumnLayout {
    anchors.fill: parent

    Label {
      id: label
      Layout.fillWidth: false

      MouseArea {
        anchors.fill: parent
        onClicked: comboBox.forceActiveFocus()
      }
    }

    ComboBox {
      id: comboBox
      model: outputModel
      textRole: internal.role
      Layout.fillWidth: true
      onCurrentValueChanged: {
        root.value = folderModel.get(comboBox.currentIndex, internal.role);
      }
    }
  }
}
