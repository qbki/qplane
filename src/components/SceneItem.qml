import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

import app

Node {
  id: root
  required property string name
  required property url source
  property vector3d ghostPosition
  property bool ghostShown: false

  function addInstanceByGhostPos() {
    if (ghostPosition) {
      addInstance(ghostPosition);
    }
  }

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
    instancesList.instances.splice(index, 1);
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

  function containsModel(obj: Model): bool {
    return getModels(instancingRoot).some((v) => v === obj);
  }

  function eachInstance(fn) {
    for (const instance of instancesList.instances) {
      fn(instance);
    }
  }

  function getPlacement(): placement {
    const placement = PlacementFactory.create();
    placement.id = root.name;
    placement.behaviour = "static";
    instancesList.instances.forEach((instance) => placement.pushPosition(instance.position));
    return placement;
  }

  function setPlacement(value: placement) {
    const positions = value.getQmlPositions();
    for (const position of positions) {
      createInstanceEntry(position);
    }
  }

  function clear() {
    instancesList.instances = [];
  }

  InstanceList {
    id: instancesList
    instances: [
    ]
  }

  RuntimeLoader {
    id: instancingRoot
    source: root.source
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

  RuntimeLoader {
    source: root.source
    visible: root.ghostShown
    position: root.ghostPosition
    opacity: 0.3
    onStatusChanged: {
      if (status === RuntimeLoader.Error) {
        console.error(errorString);
      }
    }
  }
}
