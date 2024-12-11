import QtQuick
import QtQuick3D

import app

Node {
  property string name
  /**
   * {null | () => QtQuick3D.Node}
   */
  property var factory: null
  property vector3d position: Qt.vector3d(0, 0, 0)

  id: root
  opacity: Theme.sceneOpacity

  onFactoryChanged: {
    root.children = [];
    root.factory?.(root);
  }

  onPositionChanged: {
    const child = root.children[0];
    if (child) {
      child.position = root.position;
    }
  }
}
