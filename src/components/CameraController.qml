pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Item {
  required property Camera camera
  required property Item keysCatcher
  required property MouseArea mouseCatcher

  property real speed: 10.0
  property real maxSpeed: 20.0
  property real depthSpeed: 80.0
  property real maxDepthSpeed: 180.0

  id: root

  onKeysCatcherChanged: {
    if (root.keysCatcher && inner.savedKeysCatcher !== root.keysCatcher) {
      inner.removeItselfFromCatcher();
      inner.pushItselfToCatcher();
      inner.savedKeysCatcher = root.keysCatcher;
    }
  }

  Component.onDestruction: {
    inner.removeItselfFromCatcher();
  }

  Keys.onPressed: function(event) {
    if (event.modifiers & Qt.ShiftModifier) {
      controls.maxSpeed = true;
    }

    switch (event.key) {
    case Qt.Key_W:
      controls.up = true;
      break;
    case Qt.Key_S:
      controls.down = true;
      break;
    case Qt.Key_A:
      controls.left = true;
      break;
    case Qt.Key_D:
      controls.right = true;
      break;
    }
  }

  Keys.onReleased: function(event) {
    if (!(event.modifiers & Qt.ShiftModifier)) {
      controls.maxSpeed = false;
    }

    switch (event.key) {
    case Qt.Key_W:
      controls.up = false;
      break;
    case Qt.Key_S:
      controls.down = false;
      break;
    case Qt.Key_A:
      controls.left = false;
      break;
    case Qt.Key_D:
      controls.right = false;
      break;
    }
  }

  Connections {
    target: root.mouseCatcher

    function onWheel(event) {
      if (event.angleDelta.y > 0) {
        controls.backward = true;
        inner.heightMultiplier += 1;
      } else if (event.angleDelta.y < 0) {
        controls.forward = true;
        inner.heightMultiplier += 1;
      }
    }
  }

  FrameAnimation {
    id: timer
    running: true
    onTriggered: {
      const direction = controls.getDirection();
      const speed = controls.maxSpeed ? root.maxSpeed : root.speed;
      const depthSpeed = controls.maxSpeed ? root.maxDepthSpeed : root.depthSpeed;
      const velocity = Qt.vector3d(
        direction.x * speed,
        direction.y * speed,
        direction.z * depthSpeed * inner.heightMultiplier,
      );
      root.camera.position = root.camera.position.plus(velocity.times(timer.frameTime));
      controls.forward = false;
      controls.backward = false;
      inner.heightMultiplier = 0;
    }
  }

  QtObject {
    id: controls
    property bool up: false
    property bool down: false
    property bool left: false
    property bool right: false
    property bool forward: false
    property bool backward: false
    property bool maxSpeed: false

    function getDirection(): vector3d {
      const direction = Qt.vector3d(
        controls.left ? -1 : (controls.right ? 1 : 0),
        controls.up ? 1 : (controls.down ? -1 : 0),
        controls.forward ? 1 : (controls.backward ? -1 : 0),
      );
      return direction.length() > 0 ? direction.normalized() : direction;
    }
  }

  QtObject {
    id: inner
    property Item savedKeysCatcher: null
    property vector3d direction: Qt.vector3d(0, 0, 0)
    property real heightMultiplier: 0

    function removeItselfFromCatcher() {
      if (!inner.savedKeysCatcher) {
        return;
      }
      const idx = root.keysCatcher.Keys.forwardTo.indexOf(inner.savedKeysCatcher);
      if (idx >= 0) {
        root.keysCatcher.Keys.forwardTo.splice(idx, 1);
      }
    }

    function pushItselfToCatcher() {
      root.keysCatcher.Keys.forwardTo.push(root);
    }
  }
}
