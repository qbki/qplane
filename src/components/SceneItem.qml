import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

import app

Node {
  id: root
  required property string name
  property alias source: loader.source

  function createInstanceEntry(position: vector3d) {
    const component = Qt.createComponent("QtQuick3D", "InstanceListEntry", Component.PreferSynchronous, null);
    if (component.status === Component.Ready) {
      const entry = component.createObject(null, { position });
      instancesList.instances.push(entry);
    } else if (component.status === Component.Error) {
      const where = root.source;
      const what = component.errorString();
      console.error(`${where}: ${what}`);
    }
  }

  function addInstance(position: vector3d) {
    // Avoiding placing the same model at the same place
    for (const item of instancesList.instances) {
      if (item.position.fuzzyEquals(position)) {
        return;
      }
    }
    createInstanceEntry(position);
  }

  function removeInstanceByIndex(index: int) {
    if (index >= 0 && index < instancesList.instanceCount) {
      instancesList.instances.splice(index, 1);
    }
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
      createInstanceEntry(position);
    }
  }

  function clear() {
    instancesList.instances = [];
  }

  function isEmpty() {
    return instancesList.instanceCount === 0;
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
