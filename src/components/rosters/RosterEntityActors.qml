pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import app

RosterBase {
  property string selectedEntityId: ""
  required property var modelsStore
  required property var weaponsStore
  required property var actorsStore
  required property var particlesStore

  signal itemClicked(model: entityActor)

  id: root
  name: qsTr("Actors")
  factory: EntityActorFactory
  window: Component {
    EntityActorEditWindow {
      modelsList: root.modelsStore.toArray()
      weaponsList: root.weaponsStore.toArray()
      particlesList: root.particlesStore.toArray()
    }
  }

  SystemPalette {
    id: palette
  }

  ColumnLayout {
    anchors.fill: parent

    Repeater {
      model: root.actorsStore
      delegate: RosterLabel {
        id: rosterLabel
        Layout.fillWidth: true
        background: Rectangle {
          anchors.fill: parent
          visible: rosterLabel.modelData.id === root.selectedEntityId
          color: palette.highlight
        }
        onLeftMouseClick: {
          root.itemClicked(rosterLabel.modelData);
        }
        onRightMouseClick: {
          root.itemClicked(rosterLabel.modelData);
          root.openContextMenu(rosterLabel.modelData);
        }
      }
    }
  }
}
