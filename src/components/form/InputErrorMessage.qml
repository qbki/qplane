import QtQuick

import app

Text {
  id: root
  color: Theme.errorColor
  visible: root.text.length > 0

  function getAdaptiveHeight(addition: real): real {
    return root.visible ? (root.height + addition) : 0;
  }
}
