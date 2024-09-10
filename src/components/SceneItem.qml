import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

import app

Node {
  id: root
  required property string name
  property alias source: loader.source

  function createInstanceEntry(position: vector3d): InstanceListEntry {
    const component = Qt.createComponent("QtQuick3D", "InstanceListEntry", Component.PreferSynchronous, null);
    if (component.status === Component.Ready) {
      return component.createObject(null, { position });
    } else if (component.status === Component.Error) {
      const where = root.source;
      const what = component.errorString();
      throw new Error(`${where}: ${what}`);
    }
  }

  function addInstance(position: vector3d) {
    // Avoiding placing the same model at the same place
    for (const item of instancesList.instances) {
      if (item.position.fuzzyEquals(position)) {
        return;
      }
    }
    const entry = createInstanceEntry(position);
    entry.name = root.name;
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

  function getPositionStrategy(): positionStrategyMany {
    const strategy = PositionStrategyManyFactory.create();
    strategy.entity_id = root.name;
    strategy.behaviour = "static";
    strategy.positions = instancesList.instances.map((instance) => instance.position);
    return strategy;
  }

  function addPositions(positions) {
    for (const position of positions) {
      const entry = createInstanceEntry(position);
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
