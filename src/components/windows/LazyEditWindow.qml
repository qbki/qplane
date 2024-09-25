import QtQuick
import "../../jsutils/utils.mjs" as JS

Loader {
  required property Component window

  signal accepted(newEntity: var, oldEntity: var);

  function open(entity: var) {
    if (!root.sourceComponent) {
      root.sourceComponent = root.window;
      root.item.accepted.connect(root.accepted);
      JS.fireOnce(root.item.closing, () => {
        root.item.accepted.disconnect(root.accepted);
        root.sourceComponent = undefined;
      });
    }
    root.item.open(entity);
  }

  id: root
  sourceComponent: undefined
}
