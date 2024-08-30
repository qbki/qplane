import QtQuick
import "../jsutils/utils.mjs" as JS

Loader {
  required property Component window

  function open() {
    if (!root.sourceComponent) {
      root.sourceComponent = root.window;
      JS.fireOnce(root.item.closing, () => {
        root.sourceComponent = undefined;
      });
    }
    root.item.open();
  }

  id: root
  sourceComponent: undefined
}
