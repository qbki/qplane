import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "qrc:/jsutils/utils.mjs" as JS
import app

Item {
  property alias folder: folderModel.folder;
  property alias rootFolder: folderModel.rootFolder;
  property alias label: label.text
  property alias extentions: folderModel.extentions;
  property alias errorMessage: errorMessage.text
  property alias hasEmpty: folderModel.hasEmpty
  property url value;

  id: root
  height: (label.height
           + layout.spacing
           + comboBox.height
           + errorMessage.getAdaptiveHeight(layout.spacing))

  onValueChanged: {
    inner.selectCurrentValue();
  }

  RecursiveDirectoryListModel {
    id: folderModel
    onModelReset: inner.selectCurrentValue()
    hasEmpty: true
  }

  ColumnLayout {
    id: layout
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

    InputErrorMessage {
      id: errorMessage
    }
  }

  QtObject {
    id: inner

    function selectCurrentValue() {
      const predicate = (value) => JS.areStrsEqual(value.toString(), root.value.toString());
      const index = folderModel.findIndex(predicate);
      comboBox.currentIndex = index.valid ? index.row : -1;
    }
  }
}
