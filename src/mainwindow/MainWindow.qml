import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.platform as Platform
import QtCore

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

import "../components"
import app

ApplicationWindow {
  property SceneItem currentSceneItem
  property vector3d ghostPosition
  property entityModel test

  title: appState.isProjectLoaded ? `QPlane: ${appState.projectLocalDir()}` : "QPlane"
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
      title: qsTr("Level")
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
        const json = ProjectStructure.entitiesToJson(appState, modelEntityState);
        console.log(JSON.stringify(json, null, 2));
        FileIO.saveJson(appState.levelsDir + "/entities.json", json);
      }
      if (appState.isLevelLoaded) {
        const entities = sceneItems.children.map((child) => child.getPlacement());
        const json = ProjectStructure.levelToJson(appState, entities);
        FileIO.saveJson(appState.levelPath, json);
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
    onTriggered: {
      if (!levelsEditWindowLoader.sourceComponent) {
        levelsEditWindowLoader.sourceComponent = levelsEditWindowComponent;
      }
      levelsEditWindowLoader.item.open();
    }
  }

  Action {
    id: openThemeEditWindowAction
    text: qsTr("Edit theme...")
    onTriggered: {
      if (!themeEditWindowLoader.sourceComponent) {
        themeEditWindowLoader.sourceComponent = themeEditWindowComponent;
      }
      themeEditWindowLoader.item.open();
    }
  }

  ModelEntityState {
    id: modelEntityState
  }

  AppState {
    id: appState
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

      function areStrsEqual(a: string, b: string): bool {
        return a.localeCompare(b) === 0;
      }

      function isGhostShown(model) {
        return areStrsEqual(modelEntityState.selectedModel, model.display.path);
      }

      MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onMouseXChanged: ghostPosition = view.getPlacingPosition()
        onMouseYChanged: ghostPosition = view.getPlacingPosition()
        onPressed: {
          if (currentSceneItem) {
            currentSceneItem.addInstanceByGhostPos();
          }
        }
      }

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_X) {
          const objects = pickSceneObjects()
            .filter((v) => v.objectHit !== intersectionPlane)
            .filter((v) => currentSceneItem.containsModel(v.objectHit));
          if (objects.length > 0) {
            currentSceneItem.removeInstanceByIndex(objects[0].instanceIndex);
          }
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
        id: sceneItems
        model: modelEntityState

        SceneItem {
          required property var model
          name: model.display.id
          ghostPosition: view.getGridAlignedPlacingPosition()
          ghostShown: view.isGhostShown(model)
          source: model.display.path
          onGhostShownChanged: {
            if (this.ghostShown) {
              currentSceneItem = this;
            }
          }
        }
      }

      Model {
        id: intersectionPlane
        source: "#Rectangle"
        materials: PrincipledMaterial { opacity: 0 }
        pickable: true
      }
    }

    Frame {
      id: frame
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
        contentHeight: rootLayout.height

        ScrollBar.vertical: ScrollBar {
        }

        ColumnLayout {
          id: rootLayout
          spacing: Theme.spacing(1)

          ColumnLayout {
            spacing: 0

            Label {
              text: qsTr("Models")
            }

            Grid {
              columns: 2
              spacing: 1

              Repeater {
                anchors.fill: parent
                model: modelEntityState

                EntityModelItem {
                  required property var model
                  id: item
                  name: model.display.id
                  width: frame.width / 2 - 1
                  height: frame.width / 2 - 1
                  source: model.display.path
                  selected: view.areStrsEqual(modelEntityState.selectedModel, model.display.path)
                  onClicked: function(event) {
                    if (event.button === Qt.LeftButton) {
                      modelEntityState.selectedModel = item.source;
                    } else if (event.button === Qt.RightButton) {
                      entityModelEditWindow.open((model.display));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  EntityModelEditWindow {
    id: entityModelEditWindow
    onAccepted: function(newEntityModel, originalEntityModel) {
      const idx = modelEntityState.findIndexById(originalEntityModel.id);
      if (idx.valid) {
        modelEntityState.setData(idx, newEntityModel);
      } else {
        console.error("Can't update the \"Entity Model\" model state. An item is not found")
      }
    }
  }

  Component {
    id: levelsEditWindowComponent

    LevelsEditWindow {
      id: levelsEditWindow
      levelsMetaFileUrl: appState.levelsMetaPath
      projectFolderUrl: appState.projectDir
      levelsFolderUrl: appState.levelsDir
      onClosing: levelsEditWindowLoader.sourceComponent = undefined
    }
  }

  Loader {
    id: levelsEditWindowLoader
    sourceComponent: undefined
  }

  Component {
    id: themeEditWindowComponent

    ThemeEditWindow {
      themePathUrl: appState.themePath
      projectFolderUrl: appState.projectDir
      onClosing: themeEditWindowLoader.sourceComponent = undefined
    }
  }

  Loader {
    id: themeEditWindowLoader
    sourceComponent: undefined
  }

  Platform.FolderDialog {
    id: openProjectDialog
    title: qsTr("Select an assets directory")
    onAccepted: {
      appState.projectDir = folder;
      try {
        const entitiesJson = FileIO.loadJson(appState.levelsDir + "/entities.json");
        ProjectStructure.populateEntities(entitiesJson, appState, modelEntityState);
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
        const level = ProjectStructure.parseLevel(json);
        sceneItems.children.forEach(function(sceneItem) {
          sceneItem.clear();
          const placement = level[sceneItem.name];
          if (placement) {
            sceneItem.setPlacement(placement);
          }
        });
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
      sceneItems.children.forEach(function(sceneItem) {
        sceneItem.clear();
      });
    }
  }
}
