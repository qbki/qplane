pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

RosterBase {
  required property var directionalLightsStore

  id: root
  name: qsTr("Directional Light")
  factory: EntityDirectionalLightFactory
  window: Component {
    EntityDirectionalLightEditWindow {}
  }

  ColumnLayout {
    Repeater {
      model: root.directionalLightsStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        onRightMouseClick: root.openContextMenu(rosterLabel.modelData)
      }
    }
  }
}
