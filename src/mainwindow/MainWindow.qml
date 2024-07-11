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
        }
    }

    ModelsState {
        id: modelsState
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
            environment: SceneEnvironment {
                backgroundMode: SceneEnvironment.Color
                antialiasingMode: SceneEnvironment.MSAA
                clearColor: "#dddddd"
            }

            function getPlacingPosition() {
                const objects = this.pickAll(mouseArea.mouseX, mouseArea.mouseY);
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

            function isGhostShown(model) {
                return modelsState.selectedModel.valueOf() === model.display.valueOf();
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
                model: modelsState

                SceneItem {
                    required property var model
                    ghostPosition: view.getGridAlignedPlacingPosition()
                    ghostShown: view.isGhostShown(model)
                    source: model.display
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
                    model: modelsState

                    ModelItem {
                        id: item
                        required property var model
                        width: frame.width / 2 - 1
                        height: frame.width / 2 - 1
                        source: model.display
                        selected: modelsState.selectedModel.valueOf() === model.display.valueOf()
                        onClicked: modelsState.selectedModel = item.source
                    }
                }
            }
        }
    }

    Platform.FolderDialog {
        id: openProjectDialog
        onAccepted: {
            appState.projectDir = folder;
            if (appState.isModelsDirExists) {
                modelsState.populateFromDir(appState.modelsDir);
            } else {
                console.error("\"models\" directory doesn't exists");
            }
        }
        options: Platform.FolderDialog.ShowDirsOnly
    }
}
