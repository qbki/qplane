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

  title: "QPlane"
  visible: true
  visibility: ApplicationWindow.Maximized
  menuBar: MenuBar {
    Menu {
      title: qsTr("File")

      Action {
        text: qsTr("Open assets...")
        onTriggered: openProjectDialog.open()
      }

      Action {
        text: qsTr("Save")
        onTriggered: SaveHandler.save(appState, modelEntityState)
      }
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
        } else  if (event.key === Qt.Key_S) {
          sceneItems.children.forEach(function(v) {
            v.eachInstance((v) => console.log(v));
          });
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
      SplitView.preferredWidth: 200
      SplitView.minimumWidth: 150
      SplitView.maximumWidth: 400
      padding: 0

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
              } else if (event.button === Qt.RightButton){
                entityModelEditWindow.open((model.display));
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

  Platform.FolderDialog {
    id: openProjectDialog
    onAccepted: {
      appState.projectDir = folder;
      if (appState.isModelsDirExists) {
        modelEntityState.populateFromDir(appState.modelsDir);
      } else {
        console.error("\"models\" directory doesn't exists");
      }
    }
    options: Platform.FolderDialog.ShowDirsOnly
  }
}
