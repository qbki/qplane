import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

Node {
  id: root
  required property url source
  property vector3d ghostPosition
  property bool ghostShown: false

  function addInstanceByGhostPos() {
    if (ghostPosition) {
      addInstance(ghostPosition);
    }
  }

  function addInstance(position: vector3d) {
    // Avoiding placing the same model at the same place
    for (const item of instancesList.instances) {
      if (item.position.fuzzyEquals(position)) {
        return;
      }
    }
    const component = Qt.createComponent("QtQuick3D", "InstanceListEntry", Component.PreferSynchronous, null);
    if (component.status === Component.Ready) {
      const instance = component.createObject(null, { position });
      instancesList.instances.push(instance);
    } else if (component.status === Component.Error) {
      const where = root.source;
      const what = component.errorString();
      console.error(`${where}: ${what}`);
    }
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
