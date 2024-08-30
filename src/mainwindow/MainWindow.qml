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
  property var addInstance: JS.noop
  property var removeInstance: JS.noop
  property var sceneItemsMap: JS.id({})

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
    id: saveAssetsAction
    text: qsTr("Save")
    enabled: appState.isProjectLoaded
    shortcut: StandardKey.Save
    onTriggered: {
      if (appState.isProjectLoaded) {
        const modelsJson = entityModelStore.toArray()
          .map((value) => [value.id, EntityModelFactory.toJson(value, appState.projectDir)]);
        const actorsJson = entityActorStore.toArray()
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
    id: entityModelStore

    function getById(id) {
      const index = entityModelStore.findIndex((v) => v.id === id);
      return entityModelStore.data(index, "display");
    }
  }

  GadgetListModel {
    id: entityActorStore
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

    View3D {
      id: view
      SplitView.fillWidth: true
      SplitView.fillHeight: true
      focus: true
      environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        antialiasingMode: SceneEnvironment.MSAA
        clearColor: "#dddddd"
      }

      function pickSceneObjects () {
        return this.pickAll(mouseArea.mouseX, mouseArea.mouseY);
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
        onPressed: root.addInstance()
      }

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_X) {
          root.removeInstance();
          event.accepted = true;
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
        model: entityModelStore

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
        model: entityActorStore

        SceneItem {
          required property var model

          id: actorItem
          name: model.display.id
          source: entityModelStore.getById(model.display.model_id).path
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

    Frame {
      id: roster
      SplitView.fillWidth: true
      SplitView.fillHeight: true
      SplitView.preferredWidth: Theme.spacing(25)
      SplitView.minimumWidth: Theme.spacing(18)
      SplitView.maximumWidth: Theme.spacing(50)
      padding: 0
      clip: true

      function updateEntity(entitiesStore, newEntity, oldEntity) {
        const index = entitiesStore.findIndex((storedEntity) => storedEntity.id === oldEntity.id);
        if (index.valid) {
          entitiesStore.setData(index, newEntity);
        } else {
          console.error("Invalid index");
        }
      }

      function makeEntityUpdater(entitiesStore) {
        return JS.partial(updateEntity, entitiesStore);
      }

      function clearSelection() {
        root.addInstance = JS.noop;
        entityActorListView.currentIndex = -1;
        modelGroupBox.clearSelection();
      }

      Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: rootLayout.height

        ScrollBar.vertical: ScrollBar {
        }

        ColumnLayout {
          id: rootLayout
          anchors.fill: parent
          spacing: Theme.spacing(1)

          GroupBox {
            id: entityActorBlock
            title: qsTr("Actors")
            Layout.fillWidth: true

            component ActorDelegate: Label {
              required property int index
              required property var model
              property entityActor modelData: model.display

              Layout.fillWidth: true
              Layout.fillHeight: true
              text: modelData.id
              font.pointSize: 16

              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: function(event) {
                  if (event.button === Qt.LeftButton) {
                    roster.clearSelection();
                    entityActorListView.currentIndex = index;
                    const foundEntity = entityModelStore.getById(parent.modelData.model_id);
                    const sceneItem = root.sceneItemsMap[parent.modelData.id];
                    if (foundEntity && sceneItem) {
                      root.ghostUrl = foundEntity.path;
                      root.addInstance = () => {
                        sceneItem.addInstance(root.ghostPosition);
                      };
                      root.removeInstance = () => {
                        view.pickSceneObjects()
                          .filter((v) => sceneItem.containsModel(v.objectHit))
                          .forEach((v) => sceneItem.removeInstanceByIndex(v.instanceIndex));
                      };
                    }
                  } else if (event.button === Qt.RightButton) {
                    entityActorEditWindow.open(modelData)
                    const updateActor = roster.makeEntityUpdater(entityActorStore);
                    JS.fireOnce(entityActorEditWindow.accepted, updateActor);
                  }
                }
              }
            }

            ListView {
              id: entityActorListView
              model: entityActorStore
              anchors.fill: parent
              highlight: Highlight {}
              delegate: ActorDelegate {}
            }

            ActorDelegate {
              id: actorDelegateParamsDonor
              index: -1
              model: JS.id({ display: EntityActorFactory.create() })
              visible: false
            }

            Connections {
              target: entityActorStore
              function onModelReset() {
                entityActorBlock.Layout.preferredHeight = (
                  entityActorStore.rowCount() * actorDelegateParamsDonor.height
                  + entityActorBlock.implicitLabelHeight
                  + 2 * entityActorBlock.horizontalPadding
                  + entityActorBlock.spacing
                );
              }
            }
          }

          Button {
            text: qsTr("Add Actor")
            onClicked: {
              entityActorEditWindow.open(EntityActorFactory.create());
              const addActor = (entity) => entityActorStore.append(entity);
              JS.fireOnce(entityActorEditWindow.accepted, addActor);
            }
          }

          GroupBox {
            id: modelGroupBox
            title: qsTr("Models")
            Layout.fillWidth: true

            function clearSelection() {
              for (const child of modelLayout.children) {
                if ("selected" in child) {
                  child.selected = false;
                }
              };
            }

            GridLayout {
              id: modelLayout
              columns: 2
              rowSpacing: 1
              columnSpacing: 1
              uniformCellWidths: true
              uniformCellHeights: true
              anchors.right: parent.right
              anchors.left: parent.left

              Repeater {
                id: entityModelRepeater
                model: entityModelStore

                EntityModelItem {
                  required property var model
                  property entityModel modelData: model.display
                  id: item
                  name: modelData.id
                  Layout.fillWidth: true
                  Layout.preferredHeight: modelGroupBox.width / 2
                  source: modelData.path
                  selected: false
                  onClicked: function(event) {
                    if (event.button === Qt.LeftButton) {
                      roster.clearSelection();
                      item.selected = true;
                      root.ghostUrl = modelData.path;
                      const sceneItem = root.sceneItemsMap[modelData.id];
                      if (sceneItem) {
                        root.addInstance = () => {
                          sceneItem.addInstance(root.ghostPosition);
                        }
                        root.removeInstance = () => {
                          view.pickSceneObjects()
                            .filter((v) => sceneItem.containsModel(v.objectHit))
                            .forEach((v) => sceneItem.removeInstanceByIndex(v.instanceIndex));
                        };
                      }
                    } else if (event.button === Qt.RightButton) {
                      entityModelEditWindow.open(modelData);
                      const updateModel = roster.makeEntityUpdater(entityModelStore);
                      JS.fireOnce(entityModelEditWindow.accepted, updateModel);
                    }
                  }
                }
              }
            }
          }

          Button {
            text: qsTr("Add Model")
            onClicked: {
              entityModelEditWindow.open(EntityModelFactory.create());
              const addModel = (entity) => entityModelStore.append(entity);
              JS.fireOnce(entityModelEditWindow.accepted, addModel);
            }
          }
        }
      }
    }
  }

  LazyEditWindow {
    id: entityModelEditWindow
    window: Component {
      EntityModelEditWindow {
        modelsDir: appState.modelsDir
        projectDir: appState.projectDir
      }
    }
  }

  LazyEditWindow {
    id: entityActorEditWindow
    window: Component {
      EntityActorEditWindow {
        modelsList: entityModelStore.toArray().map((v) => v.id)
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
              entityModelStore.append(entity);
            },
            "actor": () => {
              const entity = EntityActorFactory.fromJson(id, value);
              entityActorStore.append(entity);
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
