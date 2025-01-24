pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform
import QtQuick3D
import QtQuick3D.Helpers

import "qrc:/jsutils/utils.mjs" as JS
import app

ApplicationWindow {
  property var ghostModelFactory: null
  property vector3d ghostPosition: Qt.vector3d(0, 0, 0)
  property var selectedInstance: null
  property string selectedEntityId: ""

  id: root
  visible: true
  visibility: ApplicationWindow.Maximized
  menuBar: menuBar

  function reset() {
    root.ghostModelFactory = null;
    root.ghostPosition = Qt.vector3d(0, 0, 0);
    root.selectedInstance = null;
    root.selectedEntityId = "";
  }

  function isServiceObject(value) {
    return intersectionPlane === value;
  }

  function addInstance(): actionManagerItem {
    const layerId = layersView.currentLayer();
    const entityId = root.selectedEntityId;
    const sceneItem = sceneLayers.getSceneItem(layerId, entityId);
    const instances = sceneItem?.getInstancesList();
    if (!instances) {
      return null;
    }
    if (!instances.canBePlaced(root.ghostPosition)) {
      return null;
    }
    const instanceCopy = instances.createInstanceEntry({ position: root.ghostPosition });
    if (!instanceCopy) {
      return null;
    }
    const action = ActionManagerItemFactory.create(
      () => {
        const sceneItem = sceneLayers.getSceneItem(layerId, entityId);
        if (sceneItem) {
          const instances = sceneItem.getInstancesList();
          instances.pushInstance(instances.createInstanceEntry(instanceCopy));
        }
      },
      () => {
        const sceneItem = sceneLayers.getSceneItem(layerId, entityId);
        if (sceneItem) {
          const instances = sceneItem.getInstancesList();
          instances.removeInstanceById(instanceCopy.id)
        }
      }
    );
    action.execute();
    return action;
  }

  function removeInstance(): actionManagerItem {
    const closestItem = view.pickSceneObjects()
      .filter((v) => !root.isServiceObject(v.objectHit))
      .reduce((acc, v) => {
        if (acc === null) {
          return v;
        }
        const candidateLength = camera.position.minus(v.position).length();
        const storedLength = camera.position.minus(acc.position).length()
        return (storedLength < candidateLength) ? acc : v;
      }, null);
    if (closestItem) {
      const sceneItem = sceneLayers.getSceneItemOf(closestItem.objectHit);
      if (!sceneItem) {
        return null;
      }
      const { layerId, entityId } = sceneItem;
      if (layersView.currentLayer() !== layerId) {
        return null;
      }
      const instances = sceneItem.getInstancesList();
      const instance = instances.getInstance(closestItem.instanceIndex);
      const instanceCopy = instances.copyInstance(instance);
      const action = ActionManagerItemFactory.create(
        () => sceneLayers.getSceneItem(layerId, entityId)?.getInstancesList().removeInstanceById(instanceCopy.id),
        () => sceneLayers.getSceneItem(layerId, entityId)?.getInstancesList().pushInstance(instanceCopy),
      );
      action.execute();
      return action;
    }
    return null;
  }

  MenuBar {
    id: menuBar

    Menu {
      title: qsTr("File")

      MainMenuItem { action: openAssetsAction }
      MainMenuItem { action: saveAction }
    }

    Menu {
      title: qsTr("Edit")
      enabled: appState.isProjectLoaded

      MainMenuItem { action: undoAction }
      MainMenuItem { action: redoAction }
    }

    Menu {
      title: qsTr("Level")
      enabled: appState.isProjectLoaded

      MainMenuItem { action: newLevelAction }
      MainMenuItem { action: openLevelAction }
      MainMenuItem { action: openLevelsEditWindowAction }
      MainMenuItem { action: openEditSettingsWindowAction }
    }

    Menu {
      title: qsTr("Theme")
      enabled: appState.isProjectLoaded

      MainMenuItem { action: openThemeEditWindowAction }
    }
  }

  Action {
    id: openAssetsAction
    text: qsTr("Open assets...")
    enabled: !appState.isProjectLoaded
    shortcut: StandardKey.Open
    onTriggered: openProjectDialog.open()
  }

  Action {
    id: focusViewAction
    shortcut: StandardKey.Cancel
    onTriggered: {
      view.forceActiveFocus();
      root.selectedInstance = null;
      propertiesControl.reset();
    }
  }

  Action {
    id: saveAction
    text: qsTr("Save")
    enabled: appState.isProjectLoaded
    shortcut: StandardKey.Save

    function getPositionStrategies(sceneItem) {
      const strategiesMap = {};
      for (const strategyName of sceneItem.availableBehaviours) {
        const strategy = PositionStrategyManyFactory.create();
        strategy.entityId = sceneItem.entityId;
        strategy.layerId = sceneItem.layerId;
        strategy.behaviour = strategyName;
        strategiesMap[strategyName] = strategy;
      }
      for (const { position, behaviour } of sceneItem.getInstancesList().getInstances()) {
        strategiesMap[behaviour].positions.push(position);
      }
      return Object.values(strategiesMap)
        .filter((v) => v.positions.length > 0);
    }

    onTriggered: {
      if (appState.isProjectLoaded) {
        const modelsJson = modelsStore.toArray()
          .map((value) => [value.id, EntityModelFactory.toJson(value, appState.projectDir)]);
        const actorsJson = actorsStore.toArray()
          .map((value) => [value.id, EntityActorFactory.toJson(value)]);
        const weaponsJson = weaponsStore.toArray()
          .map((value) => [value.id, EntityWeaponFactory.toJson(value, appState.projectDir)]);
        const textsJson = textsStore.toArray()
          .map((value) => [value.id, EntityTextFactory.toJson(value)]);
        const particlesJson = particlesStore.toArray()
          .map((value) => [value.id, EntityParticlesFactory.toJson(value)]);
        const directionalLightsJson = directionalLightsStore.toArray()
          .map((value) => [value.id, EntityDirectionalLightFactory.toJson(value)]);
        const entities = [
          ...modelsJson,
          ...actorsJson,
          ...weaponsJson,
          ...textsJson,
          ...particlesJson,
          ...directionalLightsJson,
        ].reduce((acc, [id, value]) => {
          acc[id] = value;
          return acc;
        }, {});
        FileIO.saveJson(appState.levelsDir + "/entities.json", { entities });
      }
      if (appState.isLevelLoaded) {
        const meta = LevelMetaFactory.toJson(levelSettingsStore.meta);
        const strategies = sceneLayers
          .scenes()
          .map(JS.arity(saveAction.getPositionStrategies))
          .reduce((acc, array) => [...acc, ...array], [])
          .map(JS.arity(PositionStrategyManyFactory.toJson));
        const lights = [];
        if (levelSettingsStore.globalLightId) {
          const light = PositionStrategyVoidFactory.create();
          light.behaviour = "light"
          light.entityId = levelSettingsStore.globalLightId
          lights.push(PositionStrategyVoidFactory.toJson(light));
        }
        FileIO.saveJson(appState.levelPath, {
          meta,
          map: [...strategies, ...lights],
        });
      }
    }
  }

  Action {
    id: newLevelAction
    text: qsTr("New")
    onTriggered: newLevelDialog.open()
  }

  Action {
    id: openLevelAction
    text: qsTr("Open...")
    onTriggered: openLevelDialog.open()
  }

  Action {
    id: openLevelsEditWindowAction
    text: qsTr("Edit levels order...")
    onTriggered: levelsEditWindow.open()
  }

  Action {
    id: openThemeEditWindowAction
    text: qsTr("Edit theme...")
    onTriggered: themeEditWindow.open()
  }

  Action {
    id: openEditSettingsWindowAction
    text: qsTr("Level settings...")
    enabled: appState.isLevelLoaded
    onTriggered: {
      const { globalLightId, meta } = levelSettingsStore;
      levelSettingsWindow.open({ globalLightId, meta });
    }
  }

  Action {
    id: undoAction
    text: qsTr("Undo")
    shortcut: StandardKey.Undo
    enabled: actionManagerInstance.canUndo
    onTriggered: actionManagerInstance.undo()
  }

  Action {
    id: redoAction
    text: qsTr("Redo")
    shortcut: StandardKey.Redo
    enabled: actionManagerInstance.canRedo
    onTriggered: actionManagerInstance.redo();
  }

  component GadgetBaseModel: GadgetListModel {
    id: gadgetBaseModel
    function getById(searchId: string): var {
      const idx = gadgetBaseModel.findIndex(({ id }) => JS.areStrsEqual(id, searchId));
      return gadgetBaseModel.data(idx, "display");
    }

    function setById(searchId: string, value: var) {
      const idx = gadgetBaseModel.findIndex(({ id }) => JS.areStrsEqual(id, searchId));
      if (idx.valid) {
        gadgetBaseModel.setData(idx, value, "display");
      } else {
        gadgetBaseModel.append(value);
      }
    }

    function removeById(searchId: string) {
      gadgetBaseModel.remove(({ id }) => JS.areStrsEqual(id, searchId));
    }
  }

  GadgetBaseModel {
    id: actorsStore
  }

  GadgetBaseModel {
    id: modelsStore
  }

  GadgetBaseModel {
    id: weaponsStore
  }

  GadgetBaseModel {
    id: particlesStore
  }

  GadgetBaseModel {
    id: directionalLightsStore
  }

  GadgetBaseModel {
    id: textsStore
  }

  GadgetBaseModel {
    id: layersStore

    function addDefault() {
      const defaultLayer = LevelLayerFactory.create();
      defaultLayer.id = QmlConsts.DEFAULT_SCENE_LAYER_ID;
      defaultLayer.name = "Default";
      layersStore.append(defaultLayer);
    }
  }

  ActionManager {
    id: actionManagerInstance

    function makeCluster(list: list<var>): var {
      const execteListCopy = [...list];
      const undoListCopy = [...list].reverse();
      return ActionManagerItemFactory.create(
        () => {
          for (const action of execteListCopy) {
            action.execute();
          }
        },
        () => {
          for (const action of undoListCopy) {
            action.undo();
          }
        }
      );
    }

    function addCluster(list: list<var>) {
      const action = makeCluster(list);
      actionManagerInstance.push(action);
    }
  }

  LevelSettings {
    id: levelSettingsStore

    onGlobalLightIdChanged: {
      const light = directionalLightsStore.getById(levelSettingsStore.globalLightId);
      if (!light) {
        return;
      }
      const direction = light.direction;
      globalLight.color = light.color;
      globalLight.rotation = Quaternion.lookAt(Qt.vector3d(0, 0, 0), light.direction, camera.forward, camera.up);
    }
  }

  AppState {
    property string name: "QPlane"

    id: appState
    onLevelPathChanged: {
      const relativeLevelPath = FileIO.relativePath(appState.projectDir, appState.levelPath);
      root.title = `${appState.name}: ${relativeLevelPath}`;
    }
    Component.onCompleted: {
      root.title = appState.name;
    }
  }

  SplitView {
    anchors.fill: parent
    spacing: 0

    Item {
      SplitView.fillWidth: true
      SplitView.fillHeight: true

      View3D {
        property list<var> bufferOfRemoveActions: []
        property bool shouldRemoveInstances: false

        id: view
        anchors.fill: parent
        focus: true
        environment: SceneEnvironment {
          backgroundMode: SceneEnvironment.Color
          antialiasingMode: SceneEnvironment.MSAA
          clearColor: "#dddddd"
        }

        function pickSceneObjects () {
          return view.pickAll(mouseArea.mouseX, mouseArea.mouseY);
        }

        function getPlacingPosition() {
          const objects = pickSceneObjects();
          for (const obj of objects) {
            if (obj.objectHit === intersectionPlane) {
              return obj.scenePosition;
            }
          }
          return Qt.vector3d(0, 0, 0);
        }

        function getGridAlignedPlacingPosition() {
          const pos = getPlacingPosition();
          return Qt.vector3d(Math.floor(pos.x) + 0.5,
                             Math.floor(pos.y) + 0.5,
                             pos.z);
        }

        MouseArea {
          property list<var> bufferOfActions: []

          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          onPositionChanged: function(event) {
            root.ghostPosition = view.getGridAlignedPlacingPosition()
            if (mouseArea.pressedButtons & Qt.LeftButton) {
              const action = root.addInstance();
              if (action) {
                bufferOfActions.push(action);
              }
            }
          }
          onPressed: function(event) {
            view.forceActiveFocus();
            const action = root.addInstance();
            if (action) {
              bufferOfActions.push(action);
            }
          }
          onReleased: function(event) {
            actionManagerInstance.addCluster(bufferOfActions);
            bufferOfActions = [];
          }
        }

        Keys.onPressed: function(event) {
          switch (event.key) {
          case Qt.Key_X: {
            if (!event.isAutoRepeat) {
              view.shouldRemoveInstances = true;
            }
            break;
          }
          case Qt.Key_Q: {
            const list = view.pickSceneObjects()
            .filter((v) => !root.isServiceObject(v.objectHit));
            if (list[0]) {
              const hitResult = list[0];
              const sceneItem = sceneLayers.getSceneItemOf(hitResult.objectHit);
              if (sceneItem) {
                const instance = sceneItem.getInstancesList().getInstance(hitResult.instanceIndex);
                root.selectedEntityId = sceneItem.entityId;
                root.selectedInstance = instance;
                root.ghostModelFactory = sceneItem.getModelFactory();
                if (event.modifiers & Qt.ControlModifier) {
                  intersectionPlane.z = instance.position.z;
                }
                propertiesControl.setParams({
                  position: root.selectedInstance.position,
                  behaviour: root.selectedInstance.behaviour,
                  behavioursList: sceneItem.availableBehaviours,
                });
              }
            }
            break;
          }
          }
        }

        Keys.onReleased: function(event) {
          switch (event.key) {
          case Qt.Key_X: {
            if (event.isAutoRepeat) {
              break;
            }
            view.shouldRemoveInstances = false
            if (bufferOfRemoveActions.length > 0) {
              actionManagerInstance.addCluster(bufferOfRemoveActions);
              bufferOfRemoveActions = [];
            }
            break;
          }
          }
        }

        FrameAnimation {
          running: view.shouldRemoveInstances
          onTriggered: {
            const action = root.removeInstance();
            if (action) {
              view.bufferOfRemoveActions.push(action);
            }
          }
        }

        DirectionalLight {
          id: globalLight
          eulerRotation: Qt.vector3d(-30, -20, -40)
          ambientColor: Qt.rgba(0.05, 0.05, 0.05, 1.0)
        }

        PerspectiveCamera {
          id: camera
          clipNear: 0.001
          clipFar: 1000
          z: 20
          Component.onCompleted: camera.lookAt(Qt.vector3d(0, 0, 0))
        }

        CameraController {
          camera: camera
          keysCatcher: view
          mouseCatcher: mouseArea
        }

        AxisHelper {
          enableXYGrid: true
          enableXZGrid: false
          enableYZGrid: false
          scale: Qt.vector3d(0.01, 0.01, 0.01)
        }

        SceneLayers {
          id: sceneLayers
          actorsStore: actorsStore
          layersStore: layersStore
          modelsStore: modelsStore
          textsStore: textsStore
          translationPath: appState.translationPath
        }

        Model {
          id: intersectionPlane
          source: "#Rectangle"
          materials: PrincipledMaterial { opacity: 0 }
          pickable: true
        }

        SceneGhost {
          factory: root.ghostModelFactory
          position: root.ghostPosition
        }
      }

      HeightControl {
        value: intersectionPlane.z
        x: Theme.spacing(1)
        y: Theme.spacing(1)
        onClickedUp: intersectionPlane.z = Math.floor(intersectionPlane.z + 1.0)
        onClickedDown: intersectionPlane.z = Math.floor(intersectionPlane.z - 1.0)
      }

      PropertiesControl {
        property int lastInstanceId: -1;

        id: propertiesControl
        enabled: Boolean(root.selectedInstance)
        anchors.right: view.right
        anchors.top: view.top
        anchors.rightMargin: Theme.spacing(1)
        anchors.topMargin: Theme.spacing(1)
        onPositionChanged: {
          if (!root.selectedInstance) {
            return;
          }
          if (lastInstanceId !== root.selectedInstance.id) {
            lastInstanceId = root.selectedInstance.id;
            return;
          }
          const instanceId = root.selectedInstance.id;
          const sceneItem = JS.findParentOf(root.selectedInstance, [SceneItem, SceneTextItem]);
          if (!sceneItem) {
            return;
          }
          const { layerId, sceneId } = sceneItem;
          const originalPosition = JS.copy3dVector(root.selectedInstance.position);
          const newPosition = JS.copy3dVector(propertiesControl.position);
          if (originalPosition.fuzzyEquals(newPosition)) {
            return;
          }
          const handler = (position) => {
            const sceneItem = sceneLayers.getSceneItem(layerId, sceneId);
            const instance = sceneItem?.getInstancesList().getInstanceById(instanceId);
            if (!instance) {
              return;
            }
            root.selectedInstance = instance;
            root.selectedInstance.position = position;
            propertiesControl.setParams({
              position: root.selectedInstance.position,
              behaviour: root.selectedInstance.behaviour,
              behavioursList: sceneItem.availableBehaviours,
            });
          }
          const action = ActionManagerItemFactory.create(
            () => handler(newPosition),
            () => handler(originalPosition),
          );
          action.execute();
          actionManagerInstance.push(action);
        }
        onBehaviourChanged: {
          if (!root.selectedInstance || !propertiesControl.behaviour) {
            return;
          }
          if (lastInstanceId !== root.selectedInstance.id) {
            lastInstanceId = root.selectedInstance.id;
            return;
          }
          const instanceId = root.selectedInstance.id;
          const { layerId, entityId } = sceneLayers.getSceneItemOf(root.selectedInstance);
          const originalBehaviour = root.selectedInstance.behaviour;
          const newBehaviour = propertiesControl.behaviour;
          if (JS.areStrsEqual(originalBehaviour, newBehaviour)) {
            return;
          }
          const handler = (behaviour) => {
            const sceneItem = sceneLayers.getSceneItem(layerId, entityId);
            const instance = sceneItem?.getInstancesList().getInstanceById(instanceId);
            if (!instance) {
              return;
            }
            root.selectedInstance = instance;
            root.selectedInstance.behaviour = behaviour;
            propertiesControl.setParams({
              position: root.selectedInstance.position,
              behaviour: root.selectedInstance.behaviour,
              behavioursList: sceneItem.availableBehaviours,
            });
          }
          const action = ActionManagerItemFactory.create(
            () => handler(newBehaviour),
            () => handler(originalBehaviour),
          );
          action.execute();
          actionManagerInstance.push(action);
        }
        Component.onCompleted: {
          propertiesControl.reset();
        }
      }
    }

    Frame {
      id: roster
      SplitView.fillWidth: true
      SplitView.fillHeight: true
      SplitView.preferredWidth: Theme.spacing(25)
      SplitView.minimumWidth: Theme.spacing(18)
      SplitView.maximumWidth: Theme.spacing(50)
      padding: 0
      clip: true

      ColumnLayout {
        anchors.fill: parent

        RosterLayers {
          id: layersView
          Layout.preferredHeight: 200
          Layout.fillWidth: true
          layersStore: layersStore
          onVisibilityChanged: (layer, oldLayer) => {
            const makeHandler = (model) => () => {
              layersStore.setById(model.id, model);
            }
            const action = ActionManagerItemFactory.create(makeHandler(layer), makeHandler(oldLayer));
            action.execute();
            actionManagerInstance.push(action);
          }

          CrudSignals {
            target: layersView
            store: layersStore
            actionManager: actionManagerInstance
          }
        }

        Flickable {
          Layout.fillHeight: true
          Layout.fillWidth: true
          clip: true
          contentHeight: rosterRootLayout.implicitHeight
          ScrollBar.vertical: ScrollBar {}

          ColumnLayout {
            id: rosterRootLayout
            anchors.fill: parent
            spacing: Theme.spacing(1)

            function setupGhost(item) {
              const currentLayerId = layersView.currentLayer();
              const sceneItem = sceneLayers.getSceneItem(currentLayerId, item.id);
              if (sceneItem) {
                root.ghostModelFactory = sceneItem.getModelFactory();
              } else {
                console.error(`Scene item "${item.id}" doesn't exist`);
              }
            }

            RosterEntityActors {
              id: rosterActors
              Layout.fillWidth: true
              modelsStore: modelsStore
              actorsStore: actorsStore
              weaponsStore: weaponsStore
              particlesStore: particlesStore
              selectedEntityId: root.selectedEntityId
              onItemClicked: function(item) {
                const foundEntityModel = modelsStore.getById(item.modelId);
                if (foundEntityModel) {
                  root.selectedEntityId = item.id;
                  rosterRootLayout.setupGhost(item);
                }
              }

              CrudSignals {
                target: rosterActors
                store: actorsStore
                actionManager: actionManagerInstance
              }
            }

            RosterEntityModels {
              id: rosterModels
              Layout.fillWidth: true
              modelsStore: modelsStore
              selectedEntityId: root.selectedEntityId
              appState: appState
              onItemClicked: function(item) {
                root.selectedEntityId = item.id;
                rosterRootLayout.setupGhost(item);
              }

              CrudSignals {
                target: rosterModels
                store: modelsStore
                actionManager: actionManagerInstance
              }
            }

            RosterEntityWeapons {
              id: rosterWeapons
              Layout.fillWidth: true
              appState: appState
              weaponsStore: weaponsStore
              modelsStore: modelsStore

              CrudSignals {
                target: rosterWeapons
                store: weaponsStore
                actionManager: actionManagerInstance
              }
            }

            RosterEntityParticles {
              id: rosterParticles
              Layout.fillWidth: true
              particlesStore: particlesStore
              modelsStore: modelsStore

              CrudSignals {
                target: rosterParticles
                store: particlesStore
                actionManager: actionManagerInstance
              }
            }

            RosterEntityDirectionalLights {
              id: rosterDirectionalLights
              Layout.fillWidth: true
              directionalLightsStore: directionalLightsStore

              CrudSignals {
                target: rosterDirectionalLights
                store: directionalLightsStore
                actionManager: actionManagerInstance
              }
            }

            RosterEntityTexts {
              id: rosterTexts
              Layout.fillWidth: true
              textsStore: textsStore
              translationPath: appState.translationPath
              selectedEntityId: root.selectedEntityId
              onItemClicked: function(item) {
                const sceneItem = sceneLayers.getSceneItem(layersView.currentLayer(), item.id);
                if (sceneItem) {
                  root.selectedEntityId = item.id;
                  root.ghostModelFactory = sceneItem.getModelFactory();
                }
              }

              CrudSignals {
                target: rosterTexts
                store: textsStore
                actionManager: actionManagerInstance
              }
            }
          }
        }
      }
    }
  }

  LazyWindow {
    id: levelsEditWindow
    window: Component {
      LevelsEditWindow {
        levelsMetaFileUrl: appState.levelsMetaPath
        projectFolderUrl: appState.projectDir
        levelsFolderUrl: appState.levelsDir
      }
    }
  }

  LazyWindow {
    id: themeEditWindow
    window: Component {
      ThemeEditWindow {
        themePathUrl: appState.themePath
        projectFolderUrl: appState.projectDir
      }
    }
  }

  LazyEditWindow {
    id: levelSettingsWindow
    window: Component {
      LevelSettingsWindow {
        directionalLightsList: directionalLightsStore.toArray()
        onAccepted: function(value) {
          levelSettingsStore.globalLightId = value.globalLightId;
          levelSettingsStore.meta = value.meta;
        }
      }
    }
  }

  Platform.FolderDialog {
    id: openProjectDialog
    title: qsTr("Select an assets directory")
    onAccepted: {
      appState.projectDir = folder;
      try {
        const { entities } = FileIO.loadJson(appState.levelsDir + "entities.json");
        const entriesArray = Object.entries(entities);
        const isKindOf = (expectedKind) => ([, { kind }]) => (kind === expectedKind);

        const models = entriesArray
          .filter(isKindOf("model"))
          .map(([id, value]) => EntityModelFactory.fromJson(id, value, appState.projectDir));
        modelsStore.appendList(models);

        const actors = entriesArray
          .filter(isKindOf("actor"))
          .map(([id, value]) => EntityActorFactory.fromJson(id, value));
        actorsStore.appendList(actors);

        const weapons = entriesArray
          .filter(isKindOf("weapon"))
          .map(([id, value]) => EntityWeaponFactory.fromJson(id, value, appState.projectDir));
        weaponsStore.appendList(weapons);

        const texts = entriesArray
          .filter(isKindOf("text"))
          .map(([id, value]) => EntityTextFactory.fromJson(id, value));
        textsStore.appendList(texts);

        const particles = entriesArray
          .filter(isKindOf("particles"))
          .map(([id, value]) => EntityParticlesFactory.fromJson(id, value));
        particlesStore.appendList(particles);

        const directionalLights = entriesArray
          .filter(isKindOf("directional_light"))
          .map(([id, value]) => EntityDirectionalLightFactory.fromJson(id, value));
        directionalLightsStore.appendList(directionalLights);
      } catch(error) {
        console.error(`Assets loading error: ${error.message}`);
      }
    }
    options: Platform.FolderDialog.ShowDirsOnly
  }

  Platform.FileDialog {
    id: openLevelDialog
    title: qsTr("A level selection")
    folder: appState.levelsDir
    nameFilters: [ qsTr("Level (*.level.json)") ]

    function applyPositionStrategy(strategy: positionStrategyMany, instancesList: InstanceList) {
      const { positions, behaviour } = strategy;
      for (const position of positions) {
        const entry = instancesList.createInstanceEntry({ position, behaviour });
        instancesList.pushInstance(entry);
      }
    }

    onAccepted: {
      root.reset();
      layersStore.clear();
      levelSettingsStore.reset();
      appState.levelPath = openLevelDialog.file;
      try {
        const json = FileIO.loadJson(appState.levelPath);
        const meta = LevelMetaFactory.fromJson(json.meta);
        meta.layers.forEach(JS.arity(layersStore.append));
        levelSettingsStore.meta = meta;

        for (const strategyJson of json.map) {
          const strategy = ({
            "many": () => {
              const strategy = PositionStrategyManyFactory.fromJson(strategyJson);
              let sceneItem = sceneLayers.getSceneItem(strategy.layerId, strategy.entityId);
              if (!sceneItem) {
                sceneItem = sceneLayers.getSceneItem(QmlConsts.DEFAULT_SCENE_LAYER_ID, strategy.entityId);
              }
              if (!sceneItem) {
                layersStore.addDefault();
                sceneItem = sceneLayers.getSceneItem(QmlConsts.DEFAULT_SCENE_LAYER_ID, strategy.entityId);
              }
              if (sceneItem) {
                openLevelDialog.applyPositionStrategy(strategy, sceneItem.getInstancesList());
              } else {
                console.warn(`Can't find a render container for "${strategy.entityId}"`);
              }
            },
            "void": () => {
              const strategy = PositionStrategyVoidFactory.fromJson(strategyJson);
              if (JS.areStrsEqual(strategy.behaviour, "light")) {
                const item = directionalLightsStore.getById(strategy.entityId);
                if (item) {
                  levelSettingsStore.globalLightId = strategy.entityId;
                } else {
                  console.warn(`Entity ${strategy.entityId} was not found`);
                }
              }
            }
          })[strategyJson.kind]
          if (strategy) {
            strategy();
          } else {
            console.warn(`Unknown position strategy: ${strategyJson.kind}`);
          }
        }
      } catch(error) {
        console.error(error);
      }
    }
  }

  Platform.FileDialog {
    id: newLevelDialog
    title: qsTr("Choose a level name")
    folder: appState.levelsDir
    fileMode: Platform.FileDialog.SaveFile
    nameFilters: [ qsTr("Level (*.level.json)") ]
    onAccepted: {
      let filePath = newLevelDialog.file;
      const hasCorrectFileExtension = /.*\.level\.json$/m.test(filePath);
      if (!hasCorrectFileExtension) {
        filePath = Qt.resolvedUrl(`${filePath}.level.json`);
      }
      appState.levelPath = filePath;
      root.reset();
      layersStore.clear();
      layersStore.addDefault();
      levelSettingsStore.reset();
    }
  }
}
