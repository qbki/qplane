import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

Node {
    id: root
    required property url source

    InstanceList {
        id: instancesList
        instances: [
            InstanceListEntry {
                position: Qt.vector3d(10, 0, 0)
            }
        ]
    }

    RuntimeLoader {
        source: root.source
        instancing: instancesList
        onStatusChanged: {
            if (status === RuntimeLoader.Error) {
                console.error(errorString);
            }
        }
    }
}
