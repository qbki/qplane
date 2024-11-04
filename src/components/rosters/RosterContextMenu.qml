import QtQuick
import QtQuick.Controls

Menu {
  signal added
  signal edited(model: var)
  signal removed(model: var)

  id: root

  function reset() {
    inner.model = null;
  }

  function open(model: var) {
    inner.model = Boolean(model) ? model : null;
    root.popup();
  }

  onClosed: {
    root.reset();
  }

  MenuItem {
    text: qsTr("Add new...")
    onTriggered: root.added()
  }

  MenuItem {
    enabled: inner.hasItem()
    text: qsTr("Edit...")
    onTriggered: root.edited(inner.model)
  }

  MenuItem {
    enabled: inner.hasItem()
    text: qsTr("Remove...")
    onTriggered: root.removed(inner.model)
  }

  QtObject {
    property var model: null

    id: inner

    function hasItem() {
      return Boolean(inner.model);
    }
  }
}
