pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

import app

Node {
  required property string entityId
  property alias translationPath: translations.file
  required property entityText source
  required property string layerId
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
    const text = translations.t(entity.textId);
    return (parent) => {
      const createInstance = QmlUtils.createComponent("app", "TextTexture");
      createInstance(parent, { entity, text });
    }
  }

  Translations {
    id: translations
    onMappingChanged: {
      const { textId } = root.source;
      textTexture.text = translations.t(textId);
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
