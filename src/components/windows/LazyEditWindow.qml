import QtQuick
import "../../jsutils/utils.mjs" as JS

QtObject {
  required property Component window

  signal accepted(newEntity: var, oldEntity: var);

  id: root

  function open(entity: var) {
    if (!loader.sourceComponent) {
      loader.sourceComponent = root.window;
      loader.item.accepted.connect(root.accepted);
      JS.fireOnce(loader.item.closing, () => {
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
