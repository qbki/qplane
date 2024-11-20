pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

RosterBase {
  required property AppState appState
  required property var weaponsStore
  required property var modelsStore

  id: root
  name: qsTr("Weapons")
  factory: EntityWeaponFactory
  window: Component {
    EntityWeaponEditWindow {
      soundsDir: root.appState.soundsDir
      projectDir: root.appState.projectDir
      modelsList: root.modelsStore.toArray().map((v) => v.id)
    }
  }

  ColumnLayout {
    Repeater {
      model: root.weaponsStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        onRightMouseClick: root.openContextMenu(rosterLabel.modelData)
      }
    }
  }
}
