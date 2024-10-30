import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

Node {
  id: root
  property string name
  property alias source: loader.source
  property alias position: loader.position

  RuntimeLoader {
    id: loader
    opacity: 0.3
    onStatusChanged: {
      if (status === RuntimeLoader.Error) {
        console.error(errorString);
      }
    }
  }
}
