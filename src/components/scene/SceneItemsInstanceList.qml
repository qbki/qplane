pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

import "../../jsutils/utils.mjs" as JS
import app

InstanceList {
  required property string defaultBehaviour

  id: root

  /**
   * @param {string} props.behavior
   * @param {string} props.id
   * @param {vector3d} props.position
   * @returns {SceneListEntry}
   */
  function createInstanceEntry(props: var): var {
    const makeInstance = QmlUtils.createComponent("app", "SceneListEntry");
    return makeInstance(null, {
      id: props.id ? props.id : JS.uniqId(),
      behaviour: props.behaviour ? props.behaviour : root.defaultBehaviour,
      position: props.position,
    });
  }

  function canBePlaced(position: vector3d): bool {
    for (const item of root.instances) {
      if (item.position.fuzzyEquals(position)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @returns {SceneListEntry}
   */
  function addInstance(position: vector3d, behaviour: string): var {
    // Avoiding placing the same model at the same place
    if (canBePlaced(position)) {
      return null;
    }
    const entry = createInstanceEntry({ position, behaviour });
    root.instances.push(entry);
    return entry;
  }

  /**
   * @param {SceneListEntry} entry
   * @returns {void}
   */
  function pushInstance(entry) {
    root.instances.push(entry);
  }

  function removeInstanceByIndex(index: int) {
    const lastIndex = root.instanceCount - 1;
    if (index >= 0 && index <= lastIndex) {
      const tmp = root.instances[index];
      root.instances[index] = root.instances[lastIndex];
      root.instances[lastIndex] = tmp;
      root.instances.pop();
    }
  }

  function removeInstanceById(id: int) {
    const lastIdx = root.instances.length - 1;
    for (let i = lastIdx; i >= 0; i -= 1) {
      const item = root.instances[i];
      if (item.id === id) {
        removeInstanceByIndex(i);
        return;
      }
    }
  }

  /**
   * @param {InstanceListEntry} instance
   * @returns {void}
   */
  function removeInstance(instance: var) {
    const index = root.instances.indexOf(instance);
    root.removeInstanceByIndex(index);
  }

  function clear() {
    root.instances = [];
  }

  function isEmpty() {
    return root.instanceCount === 0;
  }

  /**
   * @returns {SceneListEntry}
   */
  function getInstanceById(id: int): var {
    for (const instance of root.instances) {
      if (instance.id === id) {
        return instance;
      }
    }
    return null;
  }

  /**
   * @throws {RangeError}
   * @returns {SceneListEntry}
   */
  function getInstance(index: int): var {
    if (index < 0 || index >= root.instanceCount) {
      throw new RangeError("Instance index is out of range");
    }
    return root.instances[index];
  }

  /**
   * @returns {list<SceneListEntry>}
   */
  function getInstances(): var {
    return root.instances;
  }

  /**
   * @param {SceneListEntry} instance
   * @returns {SceneListEntry}
   */
  function copyInstance(instance: var): var {
    return createInstanceEntry({
      id: instance.id,
      behavior: instance.behaviour,
      position: JS.copy3dVector(instance.position),
    });
  }
}
