import QtQuick
import "../../jsutils/utils.mjs" as JS

QtObject {
  /**
   * {Component | undefined}
   */
  property var window: undefined

  signal accepted(newEntity: var, oldEntity: var)
  signal closing()

  id: root

  function open(entity: var) {
    if (!root.window) {
      return;
    }
    if (!loader.sourceComponent) {
      loader.sourceComponent = root.window;
      loader.item.accepted.connect(root.accepted);
      JS.fireOnce(loader.item.closing, () => {
        root.closing();
        loader.item.accepted.disconnect(root.accepted);
        loader.sourceComponent = undefined;
      });
    }
    loader.item.open(entity);
  }

  property Loader loader: Loader {
    sourceComponent: undefined
  }
}
