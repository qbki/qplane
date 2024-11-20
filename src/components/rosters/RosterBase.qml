import QtQuick
import QtQuick.Controls

import "../../jsutils/utils.mjs" as JS
import app

GroupBox {
  required property var factory
  property alias window: editWindow.window
  property string name: ""

  signal itemAdded(model: var)
  signal itemUpdated(model: var, initialModel: var)
  signal itemRemoved(model: var)

  id: root

  function openAddWindow() {
    editWindow.open(root.factory.create());
    const unsubscribe = JS.fireOnce(editWindow.accepted, JS.arity(root.itemAdded));
    JS.fireOnce(editWindow.closing, unsubscribe);
  }

  function openUpdateWindow(model: var) {
    editWindow.open(model);
    const unsubscribe = JS.fireOnce(editWindow.accepted, JS.arity(root.itemUpdated, 2));
    JS.fireOnce(editWindow.closing, unsubscribe);
  }

  function openContextMenu(model: var) {
    contextMenu.open(model);
  }

  label: RosterTitle {
    text: root.name
    groupBox: root
    onButtonClicked: root.openAddWindow()
  }

  LazyEditWindow {
    id: editWindow
  }

  RosterContextMenu {
    id: contextMenu
    onAdded: root.openAddWindow()
    onEdited: (model) => root.openUpdateWindow(model)
    onRemoved: (model) => root.itemRemoved(model)
  }
}
