pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

RosterBase {
  required property GadgetListModel layersStore

  signal itemClicked(model: levelLayer)
  signal visibilityChanged(model: levelLayer, origModel: levelLayer)

  id: root
  name: qsTr("Layers")
  factory: LevelLayerFactory
  window: Component {
    LayerEditWindow {
      layersList: root.layersStore.toArray()
    }
  }

  function currentLayer(): string {
    return view.currentItem?.model.display.id || "";
  }

  ListView {
    id: view
    anchors.fill: parent
    model: root.layersStore
    highlight: Highlight {}
    clip: true
    delegate: RowLayout {
      required property var model
      required property int index
      id: itemLayout
      width: view.width

      RosterLabel {
        id: label
        Layout.fillWidth: true
        model: itemLayout.model
        onLeftMouseClick: {
          view.currentIndex = itemLayout.index;
        }
      }

      Label {
        Layout.preferredWidth: 20
        text: itemLayout.model.display.isVisible ? "◉" : "◎"

        MouseArea {
          anchors.fill: parent
          onClicked: {
            const origLayer = itemLayout.model.display.copy();
            const layer = origLayer.copy();
            layer.isVisible = !layer.isVisible;
            root.visibilityChanged(layer, origLayer);
          }
        }
      }
    }
  }
}
