import QtQuick

import app

QtObject {
  property levelMeta meta: LevelMetaFactory.create()
  property string globalLightId: ""

  id: root

  function reset() {
    root.meta = LevelMetaFactory.create();
    root.globalLightId = "";
  }
}
