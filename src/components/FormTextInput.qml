import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root
    property alias label: labelComponent.text
    property alias text: textField.text

    Label {
        id: labelComponent
        Layout.fillWidth: false

        MouseArea {
            anchors.fill: parent
            onClicked: textField.forceActiveFocus()
        }
    }

    TextField {
        id: textField
        Layout.fillWidth: true
    }
}
