import QtQuick
import QtQuick.Controls

import Qt.labs.platform
import QtCore

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

ApplicationWindow {
    visible: true
    width: 800
    height: 600

    View3D {
        id: view
        anchors.fill: parent

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
                camera.lookAt(Qt.vector3d(0, 0, 0));
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

    Button {
        id: importButton
        text: "Import..."
        onClicked: fileDialog.open()
        focusPolicy: Qt.NoFocus
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["glTF files (*.gltf *.glb *.obj)", "All files (*)"]
        onAccepted: importNode.source = file
    }
}
