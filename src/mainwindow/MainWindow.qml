pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform
import QtQuick3D
import QtQuick3D.Helpers

import "../jsutils/utils.mjs" as JS
import app

ApplicationWindow {
  property url ghostUrl: ""
  property vector3d ghostPosition: Qt.vector3d(0, 0, 0)
  property var selectedInstance: null
  property string selectedEntityId: ""
  property var sceneItemsMap: JS.id({})

  function isServiceObject(value) {
    return intersectionPlane === value;
  }

  function findSceneItem(sceneItemId: string): SceneItem {
    const sceneItem = sceneItemsMap[sceneItemId];
    return sceneItem ? sceneItem : null;
  }

  function addInstance(): actionManagerItem {
    const entityId = root.selectedEntityId;
    const sceneItem = root.findSceneItem(entityId);
    if (!sceneItem?.canBePlaced(root.ghostPosition)) {
      return null;
    }
    const instanceCopy = sceneItem.createInstanceEntry({ position: root.ghostPosition });
    if (!instanceCopy) {
      return null;
    }
    const action = ActionManagerItemFactory.create(
      () => {
        const sceneItem = root.findSceneItem(entityId);
        if (sceneItem) {
          sceneItem.pushInstance(sceneItem.createInstanceEntry(instanceCopy));
        }
      },
      () => {
        const sceneItem = root.findSceneItem(entityId);
        if (sceneItem) {
          sceneItem.removeInstanceById(instanceCopy.id)
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
      const sceneItem = JS.findParentOf(closestItem.objectHit, SceneItem);
      const sceneItemName = sceneItem.name;
      const instance = sceneItem.getInstance(closestItem.instanceIndex);
      const instanceCopy = sceneItem.copyInstance(instance);
      const action = ActionManagerItemFactory.create(
        () => root.findSceneItem(sceneItemName)?.removeInstanceById(instanceCopy.id),
        () => root.findSceneItem(sceneItemName)?.pushInstance(instanceCopy),
      );
      action.execute();
      return action;
    }
    return null;
  }

  function appendEntity(store, item) {
    const itemCopy = item.copy();
    const action = ActionManagerItemFactory.create(
      () => store.append(itemCopy.copy()),
      () => store.remove((value) => JS.areStrsEqual(value.id, itemCopy.id)),
    );
    action.execute();
    actionManager.push(action);
  }

  function updateEntity(store, newItem, oldItem) {
    const updater = (current, replacement) => () => {
      const index = store.findIndex((item) => JS.areStrsEqual(item.id, current.id));
      if (index.valid) {
        store.setData(index, replacement.copy(), "display");
      }
    };
    const action = ActionManagerItemFactory.create(updater(oldItem, newItem),
                                                   updater(newItem, oldItem));
    action.execute();
    actionManager.push(action);
  }

  function removeEntity(store, item) {
    const itemCopy = item.copy();
    const action = ActionManagerItemFactory.create(
      () => store.remove((value) => JS.areStrsEqual(value.id, itemCopy.id)),
      () => store.append(item.copy()),
    );
    action.execute();
    actionManager.push(action);
  }

  id: root
  visible: true
  visibility: ApplicationWindow.Maximized
  menuBar: MenuBar {
    Menu {
      title: qsTr("File")

      MainMenuItem { action: openAssetsAction }
      MainMenuItem { action: saveAssetsAction }
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
      MainMenuItem { action: openEditGlobalLightWindowAction }
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
    id: saveAssetsAction
    text: qsTr("Save")
    enabled: appState.isProjectLoaded
    shortcut: StandardKey.Save
    onTriggered: {
      if (appState.isProjectLoaded) {
        const modelsJson = modelsStore.toArray()
          .map((value) => [value.id, EntityModelFactory.toJson(value, appState.projectDir)]);
        const actorsJson = actorsStore.toArray()
          .map((value) => [value.id, EntityActorFactory.toJson(value)]);
        const weaponsJson = weaponsStore.toArray()
          .map((value) => [value.id, EntityWeaponFactory.toJson(value, appState.projectDir)]);
        const particlesJson = particlesStore.toArray()
          .map((value) => [value.id, EntityParticlesFactory.toJson(value)]);
        const directionalLightsJson = directionalLightsStore.toArray()
          .map((value) => [value.id, EntityDirectionalLightFactory.toJson(value)]);
        const entities = [
          ...modelsJson,
          ...actorsJson,
          ...weaponsJson,
          ...particlesJson,
          ...directionalLightsJson,
        ].reduce((acc, [id, value]) => {
          acc[id] = value;
          return acc;
        }, {});
        FileIO.saveJson(appState.levelsDir + "/entities.json", { entities });
      }
      if (appState.isLevelLoaded) {
        const camera = (() => {
          const entity = EntityCameraFactory.create();
          entity.position = levelSettingsStore.cameraPosition;
          return EntityCameraFactory.toJson(entity);
        })();
        const statics = sceneModelItems.children
          .filter((child) => !child.isEmpty())
          .map((child) => child.getPositionStrategies().map(JS.arity(PositionStrategyManyFactory.toJson)))
          .reduce((acc, v) => acc.concat(v), []);
        const actors = sceneActorItems.children
          .filter((child) => !child.isEmpty())
          .map((child) => child.getPositionStrategies().map(JS.arity(PositionStrategyManyFactory.toJson)))
          .reduce((acc, v) => acc.concat(v), []);
        const lights = [];
        if (levelSettingsStore.globalLightId) {
          const light = PositionStrategyVoidFactory.create();
          light.behaviour = "light"
          light.entity_id = levelSettingsStore.globalLightId
          lights.push(PositionStrategyVoidFactory.toJson(light));
        }
        FileIO.saveJson(appState.levelPath, { camera, map: [...statics, ...actors, ...lights] });
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
    id: openEditGlobalLightWindowAction
    text: qsTr("Level settings...")
    onTriggered: {
      const { globalLightId, cameraPosition } = levelSettingsStore;
      levelSettingsWindow.open({ globalLightId, cameraPosition });
    }
  }

  Action {
    id: undoAction
    text: qsTr("Undo")
    shortcut: StandardKey.Undo
    enabled: actionManager.canUndo
    onTriggered: actionManager.undo()
  }

  Action {
    id: redoAction
    text: qsTr("Redo")
    shortcut: StandardKey.Redo
    enabled: actionManager.canRedo
    onTriggered: actionManager.redo();
  }

  GadgetListModel {
    id: actorsStore
  }

  GadgetListModel {
    id: modelsStore

    function getById(id) {
      const index = modelsStore.findIndex((v) => JS.areStrsEqual(v.id, id));
      return modelsStore.data(index, "display");
    }
  }

  GadgetListModel {
    id: weaponsStore
  }

  GadgetListModel {
    id: particlesStore
  }

  GadgetListModel {
    id: directionalLightsStore
  }

  ActionManager {
    id: actionManager

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
      actionManager.push(action);
    }
  }

  LevelSettings {
    id: levelSettingsStore

    onGlobalLightIdChanged: {
      const idx = directionalLightsStore.findIndex(({ id }) => id === levelSettingsStore.globalLightId);
      if (!idx.valid) {
        return;
      }
      const light = directionalLightsStore.data(idx);
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
            actionManager.addCluster(bufferOfActions);
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
              const model = hitResult.objectHit;
              const sceneItem = JS.findParentOf(model, SceneItem);
              if (sceneItem) {
                const instance = sceneItem.getInstance(hitResult.instanceIndex);
                root.selectedEntityId = sceneItem.name;
                root.selectedInstance = instance;
                root.ghostUrl = sceneItem.source;
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
              actionManager.addCluster(bufferOfRemoveActions);
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

        Repeater3D {
          id: sceneModelItems
          model: modelsStore

          SceneItem {
            required property var model

            id: modelItem
            name: model.display.id
            defaultBehaviour: "static"
            availableBehaviours: ["static"]
            source: model.display.path
            Component.onCompleted: {
              root.sceneItemsMap[model.display.id] = modelItem;
            }
          }
        }

        Repeater3D {
          id: sceneActorItems
          model: actorsStore

          SceneItem {
            required property var model

            id: actorItem
            name: model.display.id
            defaultBehaviour: "enemy"
            availableBehaviours: ["enemy", "player"]
            source: modelsStore.getById(model.display.model_id).path
            Component.onCompleted: {
              root.sceneItemsMap[model.display.id] = actorItem;
            }
          }
        }

        Model {
          id: intersectionPlane
          source: "#Rectangle"
          materials: PrincipledMaterial { opacity: 0 }
          pickable: true
        }

        SceneGhost {
          source: root.ghostUrl
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
          const sceneItemName = JS.findParentOf(root.selectedInstance, SceneItem).name;
          const originalPosition = JS.copy3dVector(root.selectedInstance.position);
          const newPosition = JS.copy3dVector(propertiesControl.position);
          if (originalPosition.fuzzyEquals(newPosition)) {
            return;
          }
          const handler = (position) => {
            const sceneItem = root.findSceneItem(sceneItemName);
            const instance = sceneItem?.getInstanceById(instanceId);
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
          actionManager.push(action);
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
          const sceneItemName = JS.findParentOf(root.selectedInstance, SceneItem).name;
          const originalBehaviour = root.selectedInstance.behaviour;
          const newBehaviour = propertiesControl.behaviour;
          if (JS.areStrsEqual(originalBehaviour, newBehaviour)) {
            return;
          }
          const handler = (behaviour) => {
            const sceneItem = root.findSceneItem(sceneItemName);
            const instance = sceneItem?.getInstanceById(instanceId);
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
          actionManager.push(action);
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

      Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: rosterRootLayout.height

        ScrollBar.vertical: ScrollBar {
        }

        ColumnLayout {
          id: rosterRootLayout
          anchors.fill: parent
          spacing: Theme.spacing(1)

          component CrudSignals: Connections {
            required property GadgetListModel store
            function onItemAdded(item) {
              root.appendEntity(store, item);
            }
            function onItemUpdated(newItem, oldItem) {
              root.updateEntity(store, newItem, oldItem);
            }
            function onItemRemoved(item) {
              root.removeEntity(store, item);
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
              const foundEntityModel = modelsStore.getById(item.model_id);
              if (foundEntityModel) {
                root.selectedEntityId = item.id;
                root.ghostUrl = foundEntityModel.path;
              }
            }
            CrudSignals {
              target: rosterActors
              store: actorsStore
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
              root.ghostUrl = item.path;
            }
            CrudSignals {
              target: rosterModels
              store: modelsStore
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
            }
          }

          RosterEntityDirectionalLights {
            id: rosterDirectionalLights
            Layout.fillWidth: true
            directionalLightsStore: directionalLightsStore
            CrudSignals {
              target: rosterDirectionalLights
              store: directionalLightsStore
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
        model: directionalLightsStore.toArray().map(({ id }) => id)
        onAccepted: function(value) {
          levelSettingsStore.globalLightId = value.globalLightId;
          levelSettingsStore.cameraPosition = value.cameraPosition;
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
        const { entities } = FileIO.loadJson(appState.levelsDir + "/entities.json");
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

        const particles = entriesArray
          .filter(isKindOf("particles"))
          .map(([id, value]) => EntityParticlesFactory.fromJson(id, value));
        particlesStore.appendList(particles);

        const directionalLights = entriesArray
          .filter(isKindOf("directional_light"))
          .map(([id, value]) => EntityDirectionalLightFactory.fromJson(id, value));
        directionalLightsStore.appendList(directionalLights);
      } catch(error) {
        console.error(error);
      }
    }
    options: Platform.FolderDialog.ShowDirsOnly
  }

  Platform.FileDialog {
    id: openLevelDialog
    title: qsTr("A level selection")
    folder: appState.levelsDir
    nameFilters: [ qsTr("Level (*.level.json)") ]
    onAccepted: {
      appState.levelPath = openLevelDialog.file;
      try {
        const json = FileIO.loadJson(appState.levelPath);

        const camera = EntityCameraFactory.fromJson(json.camera);
        levelSettingsStore.cameraPosition = camera.position;

        const scene = [
          ...sceneModelItems.children,
          ...sceneActorItems.children,
        ].reduce(JS.reduceToObjectByField("name"), {});
        for (const strategyJson of json.map) {
          if (strategyJson.kind === "many") {
            const strategy = PositionStrategyManyFactory.fromJson(strategyJson);
            scene[strategy.entity_id]?.applyPositionStrategy(strategy);
          } else if (strategyJson.kind === "void") {
            const strategy = PositionStrategyVoidFactory.fromJson(strategyJson);
            if (JS.areStrsEqual(strategy.behaviour, "light")) {
              const idx = directionalLightsStore.findIndex((v) => JS.areStrsEqual(v.id, strategy.entity_id));
              if (idx.valid) {
                levelSettingsStore.globalLightId = strategy.entity_id;
              }
            }
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
      sceneModelItems.children.forEach(function(sceneItem) {
        sceneItem.clear();
      });
    }
  }
}
