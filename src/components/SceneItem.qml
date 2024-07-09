import QtQuick

import QtQuick3D
import QtQuick3D.AssetUtils

Node {
    id: root
    required property url source
    property vector3d ghostPosition
    property bool ghostShown: false

    function addInstanceByGhostPos() {
        if (ghostPosition) {
            addInstance(ghostPosition);
        }
    }

    function addInstance(position: vector3d) {
        const component = Qt.createComponent("QtQuick3D", "InstanceListEntry", Component.PreferSynchronous, null);
        if (component.status === Component.Ready) {
            const instance = component.createObject(null, { position });
            instancesList.instances.push(instance);
        } else if (component.status === Component.Error) {
            const where = root.source;
            const what = component.errorString();
            console.error(`${where}: ${what}`);
        }
    }

    InstanceList {
        id: instancesList
        instances: [
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

    RuntimeLoader {
        source: root.source
        visible: root.ghostShown
        position: root.ghostPosition
        opacity: 0.3
        onStatusChanged: {
            if (status === RuntimeLoader.Error) {
                console.error(errorString);
            }
        }
    }
}
