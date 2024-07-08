import Qt.labs.platform as Platform
import QtCore

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

import "../components"
import app

ApplicationWindow {
    visible: true
    visibility: ApplicationWindow.Maximized
    title: "QPlane"

    ModelsState {
        id: modelsState
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")

            Action {
                text: qsTr("Open project...")
                onTriggered: openProjectDialog.open()
            }
        }
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

            DirectionalLight {
                eulerRotation: "-30, -20, -40"
                ambientColor: "#333"
            }

            PerspectiveCamera {
                id: camera
                clipNear: 0.001
                clipFar: 1000
                position: Qt.vector3d(0, 0, 20)

                Component.onCompleted: {
                    lookAt(Qt.vector3d(0, 0, 0));
                }
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
                    source: model.display
                }
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
                        required property var model
                        width: frame.width / 2 - 1
                        height: frame.width / 2 - 1
                        source: model.display
                    }
                }
            }
        }
    }

    Platform.FolderDialog {
        id: openProjectDialog
        onAccepted: {
            modelsState.populateFromDir(folder);
        }
        options: Platform.FolderDialog.ShowDirsOnly
    }
}
