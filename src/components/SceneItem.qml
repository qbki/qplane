import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

import app

Node {
  required property string name
  required property string defaultBehaviour
  required property list<string> availableBehaviours
  property alias source: loader.source

  id: root

  function createInstanceEntry(position: vector3d, behaviour: var): InstanceListEntry {
    const component = Qt.createComponent("app", "SceneListEntry", Component.PreferSynchronous, null);
    if (component.status === Component.Ready) {
      return component.createObject(null, {
        position,
        behaviour: behaviour ? behaviour : root.defaultBehaviour,
      });
    } else if (component.status === Component.Error) {
      const where = root.source;
      const what = component.errorString();
      throw new Error(`${where}: ${what}`);
    }
  }

  function addInstance(position: vector3d, behaviour: var) {
    // Avoiding placing the same model at the same place
    for (const item of instancesList.instances) {
      if (item.position.fuzzyEquals(position)) {
        return;
      }
    }
    const entry = createInstanceEntry(position, behaviour);
    instancesList.instances.push(entry);
  }

  function removeInstanceByIndex(index: int) {
    if (index >= 0 && index < instancesList.instanceCount) {
      instancesList.instances.splice(index, 1);
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
      const entry = createInstanceEntry(position, behaviour);
      instancesList.instances.push(entry);
    }
  }

  function clear() {
    instancesList.instances = [];
  }

  function isEmpty() {
    return instancesList.instanceCount === 0;
  }

  function getInstance(index) {
    if (index < 0 || index >= instancesList.instanceCount) {
      throw new RangeError("Instance index is out of range");
    }
    return instancesList.instances[index];
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
      setPickable(this);
    }
  }
}
