import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import app

MenuItem {
  id: root

  SystemPalette {
    id: palette
    colorGroup: root.enabled ? SystemPalette.Active : SystemPalette.Disabled
  }

  contentItem: RowLayout {
    id: row

    property bool isShortcutShown: !!root.action.shortcut

    Shortcut {
      id: shortcutFormatter
      enabled: false
      sequence: root.action.shortcut
    }

    Label {
      Layout.fillWidth: true
      text: root.action.text
    }

    Rectangle {
      Layout.fillHeight: true
      width: 1
      color: palette.text
      visible: row.isShortcutShown
    }

    Label {
      Layout.minimumWidth: Theme.spacing(6)
      leftPadding: Theme.spacing(0.5)
      rightPadding: Theme.spacing(0.5)
      text: shortcutFormatter.nativeText
      visible: row.isShortcutShown
    }
  }
}
