import QtQuick

import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

View3D {
    id: view
    required property url source

    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        antialiasingMode: SceneEnvironment.MSAA
        clearColor: "#dddddd"
    }

    DirectionalLight {
        eulerRotation: Qt.vector3d(-30, -20, -40)
        ambientColor: "#333"
    }

    PerspectiveCamera {
        id: camera
        fieldOfView: 60
        clipNear: 0.001
        clipFar: 1000
    }

    RuntimeLoader {
        id: loader
        source: view.source
        onBoundsChanged: {
            const length = bounds.maximum.minus(bounds.minimum).length();
            const center = bounds.maximum.plus(bounds.minimum).times(0.5);
            camera.position = Qt.vector3d(center.x, center.y, bounds.maximum.z + length);
            camera.lookAt(Qt.vector3d(center.x, center.y, 0));
        }
        onStatusChanged: {
            if (status === RuntimeLoader.Error) {
                console.error(errorString);
            }
        }
    }
}
