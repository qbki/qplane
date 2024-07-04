import Qt.labs.platform as Platform
import QtCore

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "QPlane"

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")

            Action {
                text: qsTr("Open project...")
                onTriggered: openProjectDialog.open()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        View3D {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true

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

            RuntimeLoader {
                id: importNode
                onStatusChanged: {
                    if (status === RuntimeLoader.Error) {
                        console.error(importNode.errorString);
                    }
                }
            }

            AxisHelper {
                enableXYGrid: true
                enableXZGrid: false
                enableYZGrid: false
                scale: Qt.vector3d(0.01, 0.01, 0.01)
            }
        }

        Pane {
            Layout.fillWidth: false
            Layout.fillHeight: true
            Layout.minimumWidth: 150

            ColumnLayout {
                id: entitiesRoster
            }
        }
    }

    Platform.FolderDialog {
        id: openProjectDialog
        onAccepted: console.log(folder)
        options: Platform.FolderDialog.ShowDirsOnly
    }
}
