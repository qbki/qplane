import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

import "../jsutils/utils.mjs" as JS
import app

Node {
  required property string name
  required property string defaultBehaviour
  required property list<string> availableBehaviours
  property alias source: loader.source

  id: root

  function createInstanceEntry(props: var): SceneListEntry {
    const component = Qt.createComponent("app", "SceneListEntry", Component.PreferSynchronous, null);
    if (component.status === Component.Ready) {
      return component.createObject(null, {
        id: props.id ? props.id : JS.uniqId(),
        behaviour: props.behaviour ? props.behaviour : root.defaultBehaviour,
        position: props.position,
      });
    } else if (component.status === Component.Error) {
      const where = root.source;
      const what = component.errorString();
      throw new Error(`${where}: ${what}`);
    }
  }

  function canBePlaced(position: vector3d): bool {
    for (const item of instancesList.instances) {
      if (item.position.fuzzyEquals(position)) {
        return false;
      }
    }
    return true;
  }

  function addInstance(position: vector3d, behaviour: string): SceneListEntry {
    // Avoiding placing the same model at the same place
    if (canBePlaced(position)) {
      return null;
    }
    const entry = createInstanceEntry({ position, behaviour });
    instancesList.instances.push(entry);
    return entry;
  }

  function pushInstance(entry: SceneListEntry) {
    instancesList.instances.push(entry);
  }

  function removeInstanceByIndex(index: int) {
    const lastIndex = instancesList.instanceCount - 1;
    if (index >= 0 && index <= lastIndex) {
      const tmp = instancesList.instances[index];
      instancesList.instances[index] = instancesList.instances[lastIndex];
      instancesList.instances[lastIndex] = tmp;
      instancesList.instances.pop();
    }
  }

  function removeInstanceById(id: int) {
    const lastIdx = instancesList.instances.length - 1;
    for (let i = lastIdx; i >= 0; i -= 1) {
      const item = instancesList.instances[i];
      if (item.id === id) {
        removeInstanceByIndex(i);
        return;
      }
    }
  }

  function removeInstance(instance: InstanceListEntry) {
    const index = instancesList.instances.indexOf(instance);
    root.removeInstanceByIndex(index);
  }

  function setPickable(obj) {
    for (let child of getModels(obj)) {
      child.pickable = true;
    }
  }

  function getModels(obj): list<Model> {
    if (obj instanceof Model) {
      return [obj];
    }
    if (!obj || !obj.children) {
      return [];
    }
    let result = [];
    for (const child of obj.children) {
      result = [...result, ...getModels(child)];
    }
    return result;
  }

  function containsModel(model: Model): bool {
    return getModels(loader).some((v) => (v === model));
  }

  function eachInstance(fn) {
    for (const instance of instancesList.instances) {
      fn(instance);
    }
  }

  function getPositionStrategies(): list<positionStrategyMany> {
    const stragegiesMap = {};
    for (const strategyName of availableBehaviours) {
      const strategy = PositionStrategyManyFactory.create();
      strategy.entity_id = root.name;
      strategy.behaviour = strategyName;
      stragegiesMap[strategyName] = strategy;
    }
    for (const { position, behaviour } of instancesList.instances) {
      stragegiesMap[behaviour].positions.push(position);
    }
    return Object.values(stragegiesMap)
      .filter((v) => v.positions.length > 0);
  }

  function applyPositionStrategy(strategy: positionStrategyMany) {
    const { positions, behaviour } = strategy;
    for (const position of positions) {
      const entry = createInstanceEntry({ position, behaviour });
      instancesList.instances.push(entry);
    }
  }

  function clear() {
    instancesList.instances = [];
  }

  function isEmpty() {
    return instancesList.instanceCount === 0;
  }

  function getInstanceById(id: int): SceneListEntry {
    for (const instance of instancesList.instances) {
      if (instance.id === id) {
        return instance;
      }
    }
    return null;
  }

  function getInstance(index: int): SceneListEntry {
    if (index < 0 || index >= instancesList.instanceCount) {
      throw new RangeError("Instance index is out of range");
    }
    return instancesList.instances[index];
  }

  function copyInstance(instance: SceneListEntry): SceneListEntry {
    return createInstanceEntry({
      id: instance.id,
      behavior: instance.behaviour,
      position: JS.copy3dVector(instance.position),
    });
  }

  InstanceList {
    id: instancesList
    instances: [
    ]
  }

  RuntimeLoader {
    id: loader
    instancing: instancesList
    onStatusChanged: {
      if (status === RuntimeLoader.Error) {
        console.error(errorString);
      }
    }
    onBoundsChanged: {
      root.setPickable(this);
    }
  }
}
