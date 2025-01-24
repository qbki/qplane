pragma ComponentBehavior: Bound
import QtQuick

import app

QtObject {
  property alias target: connections.target
  required property ActionManager actionManager
  required property GadgetListModel store

  id: root

  /**
   * Can't use Connections as a root component because
   * it ignores properties passed during instantiation.
   */
  property var _connections: Connections {
    id: connections

    function onItemAdded(item) {
      const itemCopy = item.copy();
      const action = ActionManagerItemFactory.create(
        () => root.store.append(itemCopy.copy()),
        () => root.store.removeById(itemCopy.id),
      );
      action.execute();
      root.actionManager.push(action);
    }

    function onItemUpdated(newItem, oldItem) {
      const updater = (current, replacement) => () => {
        store.setById(current.id, replacement.copy());
      };
      const action = ActionManagerItemFactory.create(updater(oldItem, newItem),
                                                     updater(newItem, oldItem));
      action.execute();
      root.actionManager.push(action);
    }

    function onItemRemoved(item) {
      const itemCopy = item.copy();
      const action = ActionManagerItemFactory.create(
        () => root.store.removeById(itemCopy.id),
        () => root.store.append(item.copy()),
      );
      action.execute();
      root.actionManager.push(action);
    }
  }
}
