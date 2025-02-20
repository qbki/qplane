pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

import "qrc:/jsutils/utils.mjs" as JS
import app

Node {
  required property GadgetListModel actorsStore
  required property GadgetListModel layersStore
  required property GadgetListModel modelsStore
  required property GadgetListModel textsStore
  required property url translationPath

  id: root

  function getSceneItem(layerId: string, entityId: string): var {
    const value = inner.scenesMapping?.[layerId]?.[entityId];
    return value || null;
  }

  function getSceneItemOf(model) {
    return JS.findParentOf(model, [SceneItem, SceneTextItem]);
  }

  function scenes() {
    return Object
      .values(inner.scenesMapping)
      .reduce((acc, scenes) => [...acc, ...Object.values(scenes)], []);
  }

  Repeater3D {
    model: root.layersStore

    Node {
      required property var model
      property string layerId: wrapper.model.data.id
      id: wrapper
      visible: wrapper.model.data.isVisible
      Component.onDestruction: delete inner.scenesMapping[wrapper.layerId]

      Repeater3D {
        model: root.modelsStore

        SceneItem {
          required property var model
          id: modelItem
          entityId: modelItem.model.data.id
          layerId: wrapper.layerId
          defaultBehaviour: "static"
          availableBehaviours: ["static"]
          source: model.data.path
          Component.onCompleted: inner.cacheScene(modelItem)
          Component.onDestruction: inner.removeFromSceneCache(modelItem)
        }
      }

      Repeater3D {
        model: root.actorsStore

        SceneItem {
          required property var model
          id: actorItem
          entityId: model.data.id
          layerId: wrapper.layerId
          defaultBehaviour: "enemy"
          availableBehaviours: ["enemy", "player"]
          source: root.modelsStore.getById(model.data.modelId).path
          Component.onCompleted: inner.cacheScene(actorItem)
          Component.onDestruction: inner.removeFromSceneCache(actorItem)
        }
      }

      Repeater3D {
        model: root.textsStore

        SceneTextItem {
          required property var model
          id: textItem
          entityId: model.data.id
          layerId: wrapper.layerId
          translationPath: root.translationPath
          source: model.data
          defaultBehaviour: "static"
          availableBehaviours: ["static"]
          Component.onCompleted: inner.cacheScene(textItem)
          Component.onDestruction: inner.removeFromSceneCache(textItem)
        }
      }
    }
  }

  QtObject {
    id: inner
    property var scenesMapping: JS.id({})

    function cacheScene(scene) {
      try {
        if (!(scene.layerId in inner.scenesMapping)) {
          inner.scenesMapping[scene.layerId] = {}
        }
        inner.scenesMapping[scene.layerId][scene.entityId] = scene;
      } catch(error) {
        console.error(`Can't put a scene item into mapping: ${error.message}`);
      }
    }

    function removeFromSceneCache(scene) {
      delete inner.scenesMapping?.[scene.layerId]?.[scene.entityId];
    }
  }
}
