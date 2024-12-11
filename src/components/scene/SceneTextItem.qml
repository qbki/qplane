pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

import app

Node {
  required property string entityId
  required property AppState appState
  required property entityText source
  required property string defaultBehaviour
  required property list<string> availableBehaviours

  id: root

  function getInstancesList(): SceneItemsInstanceList {
    return instancesList;
  }

  /**
   * @returns {(parent: QObject) => void}
   */
  function getModelFactory(): var {
    const entity = root.source;
    const text = translations.t(entity.text_id);
    return (parent) => {
      const createInstance = QmlUtils.createComponent("app", "TextTexture");
      createInstance(parent, { entity, text });
    }
  }

  Translations {
    id: translations
    file: root.appState.isProjectLoaded ? root.appState.translationPath : null
    onMappingChanged: {
      const { text_id } = root.source;
      textTexture.text = translations.t(text_id);
    }
  }

  SceneItemsInstanceList {
    id: instancesList
    defaultBehaviour: root.defaultBehaviour
  }

  TextTexture {
    id: textTexture
    instancing: instancesList
    entity: root.source
    pickable: true
    text: ""
  }
}
