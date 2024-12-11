import QtQuick
import QtQuick3D
import QtQuick3D.AssetUtils

import app

Node {
  required property string entityId
  required property string defaultBehaviour
  required property list<string> availableBehaviours
  property alias source: loader.source

  id: root

  function getInstancesList(): SceneItemsInstanceList {
    return instancesList;
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

  /**
   * @returns {(parent: QObject) => void}
   */
  function getModelFactory() {
    const source = root.source;
    return (parent) => {
      const makeInstance = QmlUtils.createComponent("QtQuick3D.AssetUtils", "RuntimeLoader");
      makeInstance(parent, { source });
    }
  }

  SceneItemsInstanceList {
    id: instancesList
    defaultBehaviour: root.defaultBehaviour
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
      for (let child of root.getModels(loader)) {
        child.pickable = true;
      }
    }
  }
}
