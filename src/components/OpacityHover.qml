import QtQuick
import QtQuick.Controls

import app

Item {
  layer.enabled: true
  opacity: hover.hovered ? 1.0 : Theme.sceneOpacity

  HoverHandler {
    id: hover
  }
}
