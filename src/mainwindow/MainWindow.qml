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

  onSelectedEntityIdChanged: {
    const entityId = root.selectedEntityId;
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
      propertiesControl.position = Qt.vector3d(0, 0, 0);
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
        const entities = [
          ...modelsJson,
          ...actorsJson,
        ].reduce((acc, [id, value]) => {
          acc[id] = value;
          return acc;
        }, {});
        // TODO: Placeholder, it should be removed after implementation of light entity.
        //       But I need it here for testing new features with the plane engine.
        entities["sun_light"] = {
          kind: "directional_light",
          color: [1, 1, 1],
          direction: [-0.8, -0.8, -1.0]
        };
        FileIO.saveJson(appState.levelsDir + "/entities.json", { entities });
      }
      if (appState.isLevelLoaded) {
        // TODO: Placeholder, it should be removed after implementation of a camera screen (or its substitution).
        //       But I need it here for testing new features with the plane engine.
        const camera = {
          "position": [0.0, 0.0, 30.0]
        };
        const statics = sceneModelItems.children
          .filter((child) => !child.isEmpty())
          .map((child) => PositionStrategyManyFactory.toJson(child.getPositionStrategy()));
        const actors = sceneActorItems.children
          .filter((child) => !child.isEmpty())
          .map((child) => PositionStrategyManyFactory.toJson(child.getPositionStrategy()))
          .map((strategy) => {
            strategy.behaviour = "player";
            return strategy;
          });
        const light = {
          kind: "void",
          behaviour: "light",
          entity_id: "sun_light"
        };
        FileIO.saveJson(appState.levelPath, { camera, map: [...statics, ...actors, light] });
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

  GadgetListModel {
    id: modelsStore

    function getById(id) {
      const index = modelsStore.findIndex((v) => v.id === id);
      return modelsStore.data(index, "display");
    }
  }

  GadgetListModel {
    id: actorsStore
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
          onMouseXChanged: root.ghostPosition = view.getGridAlignedPlacingPosition()
          onMouseYChanged: root.ghostPosition = view.getGridAlignedPlacingPosition()
          onPressed: {
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
                propertiesControl.position = root.selectedInstance.position;
                root.ghostUrl = sceneItem.source;
              }
            }
          }
        }

        DirectionalLight {
          eulerRotation: "-30, -20, -40"
          ambientColor: "#333"
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
        position: Qt.vector3d(0, 0, 0)
        onPositionChanged: {
          if (root.selectedInstance) {
            root.selectedInstance.position = propertiesControl.position;
          }
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

  Platform.FolderDialog {
    id: openProjectDialog
    title: qsTr("Select an assets directory")
    onAccepted: {
      appState.projectDir = folder;
      try {
        const { entities } = FileIO.loadJson(appState.levelsDir + "/entities.json");
        for (const [id, value] of Object.entries(entities)) {
          const mapping = {
            "model": () => {
              const entity = EntityModelFactory.fromJson(id, value, appState.projectDir);
              modelsStore.append(entity);
            },
            "actor": () => {
              const entity = EntityActorFactory.fromJson(id, value);
              actorsStore.append(entity);
            }
          }
          const handler = mapping[value.kind];
          if (handler) {
            handler();
          } else {
            console.warn(`Unknown kind: ${value.kind}`);
          }
        }
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

        const scene = [
          ...sceneModelItems.children,
          ...sceneActorItems.children
        ].reduce(JS.reduceToObjectByField("name"), {});
        for (const strategyJson of json.map) {
          if (strategyJson.kind === "many") {
            const strategy = PositionStrategyManyFactory.fromJson(strategyJson);
            scene[strategy.entity_id]?.addPositions(strategy.positions);
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
