#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>

#include "src/types/entitymodel.h"

#include "appstate.h"
#include "modelentitystate.h"
#include "savehandler.h"

SaveHandler::SaveHandler(QObject* parent)
  : QObject{ parent }
{
}

QJsonObject toJson(AppState* appState, const EntityModel& value) {
  QJsonObject result;
  QDir dir(appState->projectDir().toLocalFile());
  auto relativePath = dir.relativeFilePath(value.path().toString());
  result.insert("kind", "model");
  result.insert("path", relativePath);
  result.insert("is_opaque", value.isOpaque());
  return result;
}

void SaveHandler::save(AppState* appState, ModelEntityState* modelEntityState)
{
  QJsonObject root;
  QJsonObject entities;

  for (auto& item : modelEntityState->internalData()) {
    entities.insert(item.id(), toJson(appState, item));
  }
  root.insert("entities", entities);

  QJsonDocument json {root};

  auto levelsDir = QDir(appState->levelsDir().toLocalFile());
  if (levelsDir.mkpath(".")) {
    auto entitiesPath = levelsDir.filePath("./entities.json");
    QFile entitiesFile {entitiesPath};
    if (entitiesFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
      entitiesFile.write(json.toJson());
      entitiesFile.close();
    } else {
      qWarning() << QString("Can't create \"%1\" file").arg(entitiesPath);
    }
  } else {
    qWarning() << QString("Can't create \"%1\" directory").arg(levelsDir.canonicalPath());
  }
}
