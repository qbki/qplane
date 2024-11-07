import QtQuick

import app

QtObject {
  property levelMeta meta: LevelMetaFactory.create()
  property string globalLightId: ""
}
