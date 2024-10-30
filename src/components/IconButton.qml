import QtQuick

Item {
  required property var icon
  signal clicked(MouseEvent event)

  id: root

  QtObject {
    id: inner
    property color savedColor
  }

  SystemPalette {
    id: palette
  }

  HoverHandler {
    id: hover
    onHoveredChanged: {
      root.icon.strokeColor = hover.hovered
        ? palette.highlight
        : inner.savedColor;
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
  }

  Component.onCompleted: {
    data.push(icon);
    inner.savedColor = icon.strokeColor;
    icon.anchors.fill = root;
    mouse.clicked.connect(root.clicked);
  }
}
