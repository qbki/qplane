#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

#include "src/types/entitymodel.h"

#include "appstate.h"
#include "modelentitystate.h"
#include "projectstructure.h"

ProjectStructure::ProjectStructure(QObject* parent)
  : QObject{ parent }
{
}

QJsonObject
toJson(AppState* appState, const EntityModel& value) {
  QJsonObject result;
  QDir dir(appState->projectDir().toLocalFile());
  auto relativePath = dir.relativeFilePath(value.path().toString());
  result.insert("kind", "model");
  result.insert("path", relativePath);
  result.insert("is_opaque", value.isOpaque());
  return result;
}

void
checkRequiredKey(const QJsonObject& object, const QString& key) {
  if (!object.contains(key)) {
    throw std::runtime_error(QString("The \"%1\" key is required").arg(key).toStdString());
  }
}

void
checkString(const QJsonObject& object, const QString& key)
{
  if (!object.contains(key)) {
    return;
  }
  if (!object.value(key).isString()) {
    throw std::runtime_error(QString("The \"%1\" key is not a string").arg(key).toStdString());
  }
}

void
checkBoolean(const QJsonObject& object, const QString& key)
{
  if (!object.contains(key)) {
    return;
  }
  if (!object.value(key).isBool()) {
    throw std::runtime_error(QString("The \"%1\" key is not a boolean value").arg(key).toStdString());
  }
}

void
checkObject(const QJsonObject& object, const QString& key)
{
  if (!object.contains(key)) {
    return;
  }
  if (!object.value(key).isObject()) {
    throw std::runtime_error(QString("The \"%1\" key is not an object").arg(key).toStdString());
  }
}

void fromJson(const std::vector<EntityModel>& entities, ModelEntityState* modelEntityState)
{
  modelEntityState->updateWholeModel(entities);
}

void
ProjectStructure::save(AppState* appState, ModelEntityState* modelEntityState)
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

EntityModel fromJsonToEntityModel(const QJsonObject& value,
                                  const AppState& appState,
                                  const QString& id) {
  checkRequiredKey(value, "path");
  checkString(value, "path");
  checkRequiredKey(value, "is_opaque");
  checkBoolean(value, "is_opaque");
  auto projectDir = QDir(appState.projectDir().toLocalFile());
  EntityModel result {};
  result.setId(id);
  result.setPath(projectDir.filePath(value.value("path").toString()));
  result.setIsOpaque(value.value("is_opaque").toBool());
  return result;
}

void
ProjectStructure::load(AppState* appState, ModelEntityState* modelEntityState)
{
  auto levelsDir = QDir(appState->levelsDir().toLocalFile());
  auto entitiesPath = levelsDir.filePath("./entities.json");
  QJsonDocument doc;

  QFile entitiesFile {entitiesPath};
  if (entitiesFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
    auto rawData = entitiesFile.readAll();
    doc = QJsonDocument::fromJson(rawData);
    entitiesFile.close();
  } else {
    qWarning() << QString("Can't read \"%1\" file").arg(entitiesPath);
    return;
  }

  auto root = doc.object();
  checkRequiredKey(root, "entities");
  checkObject(root, "entities");
  auto entities = root.value("entities").toObject();
  std::vector<EntityModel> entityModelList;
  std::unordered_map<QString, QJsonObject> kindMapping;
  for (const auto& id: entities.keys()) {
    auto value = entities.value(id).toObject();
    checkRequiredKey(value, "kind");
    checkString(value, "kind");
    if (value.value("kind").toString().toStdString() == "model") {
      auto model = fromJsonToEntityModel(value, *appState, id);
      entityModelList.push_back(model);
    }
  }
  modelEntityState->updateWholeModel(entityModelList);
}
