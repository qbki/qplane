pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

RosterBase {
  required property var particlesStore
  required property var modelsStore

  id: root
  name: qsTr("Particles")
  factory: EntityParticlesFactory
  window: Component {
    EntityParticlesEditWindow {
      modelsList: modelsStore.toArray()
    }
  }

  ColumnLayout {
    Repeater {
      model: root.particlesStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        onRightMouseClick: root.openContextMenu(rosterLabel.modelData)
      }
    }
  }
}
