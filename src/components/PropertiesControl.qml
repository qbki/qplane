import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

OpacityHover {
  property alias position: positionField.value
  property alias behaviour: behaviourField.value
  property alias behavioursList: behaviourField.model

  id: root
  width: 150
  height: pane.height

  function reset() {
    root.position = Qt.vector3d(0, 0, 0);
    root.behaviour = "";
  }

  function setParams({ behaviour, behavioursList, position }) {
    propertiesControl.position = position;
    propertiesControl.behavioursList = behavioursList;
    propertiesControl.behaviour = behaviour;
  }

  SystemPalette {
    id: palette
  }

  Pane {
    id: pane
    width: root.width
    padding: Theme.spacing(1)
    background: Rectangle {
      radius: Theme.spacing(1)
      color: palette.window
    }

    ColumnLayout {
      id: layout
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: Theme.spacing(1)

      FormVector3DInput {
        id: positionField
        Layout.fillWidth: true
        label: qsTr("Position")
      }

      FormComboBoxInput {
        id: behaviourField
        Layout.fillWidth: true
        label: qsTr("Behaviour")
      }
    }
  }
}
