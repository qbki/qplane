import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel as Platform

import "../../jsutils/utils.mjs" as JS
import app

Item {
  property alias folder: folderModel.folder;
  property alias rootFolder: folderModel.rootFolder;
  property alias label: label.text
  property alias extentions: folderModel.extentions;
  property url value;

  id: root
  height: label.height + comboBox.height

  onValueChanged: {
    internal.selectCurrentValue();
  }

  QtObject {
    id: internal

    function selectCurrentValue() {
      const predicate = (value) => JS.areStrsEqual(value.toString(), root.value.toString());
      const index = folderModel.findIndex(predicate);
      comboBox.currentIndex = index.valid ? index.row : -1;
    }
  }

  RecursiveDirectoryListModel {
    id: folderModel
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
      model: folderModel
      valueRole: "value"
      textRole: "text"
      Layout.fillWidth: true
      currentIndex: -1
      onCurrentValueChanged: {
        if (root.value !== comboBox.currentValue) {
          root.value = comboBox.currentValue;
        }
      }
    }
  }
}
