import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.platform as Platform
import QtCore

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

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

  function addInstance() {
    const sceneItem = sceneItemsMap[root.selectedEntityId];
    if (sceneItem) {
      sceneItem.addInstance(root.ghostPosition);
    }
  }

  function removeInstance() {
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
      sceneItem.removeInstanceByIndex(closestItem.instanceIndex);
    }
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

  GadgetListModel {
    id: actorsStore
  }

  GadgetListModel {
    id: modelsStore

    function getById(id) {
      const index = modelsStore.findIndex((v) => v.id === id);
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

  LevelSettings {
    id: levelSettingsStore

    onGlobalLightIdChanged: {
      const idx = directionalLightsStore.findIndex(({ id }) => id === levelSettingsStore.globalLightId);
      if (!idx.valid) {
        return;
      }
      const light = directionalLightsStore.data(idx);
      globalLight.color = light.color;
      const direction = light.direction;
      const rotation = Quaternion.lookAt(Qt.vector3d(0, 0, 0), light.direction, camera.forward, camera.up);
      globalLight.rotation = rotation;
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
      root.title = appState.name
    }
  }

  SplitView {
    anchors.fill: parent
    spacing: 0

    Item {
      SplitView.fillWidth: true
      SplitView.fillHeight: true

      View3D {
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
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          onPositionChanged: function (event) {
            root.ghostPosition = view.getGridAlignedPlacingPosition()
            if (mouseArea.pressedButtons & Qt.LeftButton) {
              root.addInstance();
            }
          }
          onPressed: function (event) {
            view.forceActiveFocus();
            root.addInstance();
          }
        }

        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_X) {
            root.removeInstance();
          } else if (event.key === Qt.Key_Q) {
            const list = view.pickSceneObjects()
              .filter((v) => !root.isServiceObject(v.objectHit));
            if (list[0]) {
              const hitResult = list[0];
              const model = hitResult.objectHit;
              const sceneItem = JS.findParentOf(model, SceneItem);
              if (sceneItem) {
                root.selectedEntityId = sceneItem.name;
                root.selectedInstance = sceneItem.getInstance(hitResult.instanceIndex);
                root.ghostUrl = sceneItem.source;
                propertiesControl.setParams({
                  position: root.selectedInstance.position,
                  behaviour: root.selectedInstance.behaviour,
                  behavioursList: sceneItem.availableBehaviours,
                });
              }
            }
          }
        }

        DirectionalLight {
          id: globalLight
          eulerRotation: "-30, -20, -40"
          ambientColor: Qt.rgba(0.05, 0.05, 0.05, 1.0)
        }

        PerspectiveCamera {
          id: camera
          clipNear: 0.001
          clipFar: 1000
          position: Qt.vector3d(0, 0, 20)
          frustumCullingEnabled: true
          Component.onCompleted: lookAt(Qt.vector3d(0, 0, 0))
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
        id: propertiesControl
        enabled: Boolean(root.selectedInstance)
        anchors.right: view.right
        anchors.top: view.top
        anchors.rightMargin: Theme.spacing(1)
        anchors.topMargin: Theme.spacing(1)
        onPositionChanged: {
          if (root.selectedInstance) {
            root.selectedInstance.position = propertiesControl.position;
          }
        }
        onBehaviourChanged: {
          if (root.selectedInstance && propertiesControl.behaviour) {
            root.selectedInstance.behaviour = propertiesControl.behaviour;
          }
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

          GroupBox {
            title: qsTr("Actors")
            Layout.fillWidth: true

            RosterEntityActors {
              modelsStore: modelsStore
              actorsStore: actorsStore
              weaponsStore: weaponsStore
              particlesStore: particlesStore
              selectedEntityId: root.selectedEntityId
              anchors.left: parent.left
              anchors.right: parent.right
              onItemClicked: function(modelData) {
                const foundEntityModel = modelsStore.getById(modelData.model_id);
                if (foundEntityModel) {
                  root.selectedEntityId = modelData.id;
                  root.ghostUrl = foundEntityModel.path;
                }
              }
            }
          }

          GroupBox {
            title: qsTr("Models")
            Layout.fillWidth: true

            RosterEntityModels {
              modelsStore: modelsStore
              selectedEntityId: root.selectedEntityId
              appState: appState
              anchors.left: parent.left
              anchors.right: parent.right
              onItemClicked: function(modelData) {
                root.selectedEntityId = modelData.id;
                root.ghostUrl = modelData.path;
              }
            }
          }

          GroupBox {
            title: qsTr("Weapons")
            Layout.fillWidth: true

            RosterEntityWeapons {
              appState: appState
              weaponsStore: weaponsStore
              modelsStore: modelsStore
              anchors.left: parent.left
              anchors.right: parent.right
            }
          }

          GroupBox {
            title: qsTr("Particles")
            Layout.fillWidth: true

            RosterEntityParticles {
              particlesStore: particlesStore
              modelsStore: modelsStore
              anchors.left: parent.left
              anchors.right: parent.right
            }
          }

          GroupBox {
            title: qsTr("Directional Light")
            Layout.fillWidth: true

            RosterEntityDirectionalLights {
              directionalLightsStore: directionalLightsStore
              anchors.left: parent.left
              anchors.right: parent.right
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
