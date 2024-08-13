#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <algorithm>

#include "src/types/entitymodel.h"

#include "appstate.h"
#include "modelentitystate.h"
#include "placement.h"
#include "projectstructure.h"

ProjectStructure::ProjectStructure(QObject* parent)
  : QObject{ parent }
{
}

QJsonObject
toJson(const AppState& appState, const EntityModel& value) {
  QJsonObject result;
  QDir dir(appState.projectDir().toLocalFile());
  auto relativePath = dir.relativeFilePath(value.path().toString());
  result.insert("kind", "model");
  result.insert("path", relativePath);
  result.insert("is_opaque", value.isOpaque());
  return result;
}

QJsonArray
toJson(const AppState& appState, const Placement& value) {
  QJsonArray result;
  for (const auto& position: value.getPositions()) {
    QJsonObject jsonPlacement;
    jsonPlacement.insert("kind", "single");
    jsonPlacement.insert("entity_id", value.id());
    jsonPlacement.insert("bahaviour", value.behaviour());
    QJsonArray jsonPosition;
    jsonPosition.push_back(position.x());
    jsonPosition.push_back(position.y());
    jsonPosition.push_back(position.z());
    jsonPlacement.insert("position", jsonPosition);
    result.push_back(jsonPlacement);
  }
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

void
checkArray(const QJsonObject& object, const QString& key)
{
  if (!object.contains(key)) {
    return;
  }
  if (!object.value(key).isArray()) {
    throw std::runtime_error(QString("The \"%1\" key is not an array").arg(key).toStdString());
  }
}

void fromJson(const std::vector<EntityModel>& entities, ModelEntityState* modelEntityState)
{
  modelEntityState->updateWholeModel(entities);
}

QJsonValue
ProjectStructure::entitiesToJson(AppState* appState, ModelEntityState* modelEntityState)
{
  QJsonObject root;
  QJsonObject entities;
  for (auto& item : modelEntityState->internalData()) {
    entities.insert(item.id(), toJson(*appState, item));
  }
  root.insert("entities", entities);
  return root;
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
ProjectStructure::populateEntities(const QJsonValue& json, AppState* appState, ModelEntityState* modelEntityState)
{
  auto root = json.toObject();
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

QJsonValue
ProjectStructure::levelToJson(AppState* appState, const QVariant& placedEntities)
{
  if (appState->levelPath().isEmpty()) {
    qDebug() << "A level's file path was not specified";
    return {};
  }
  QJsonArray map;
  for (const auto& item : placedEntities.toList()) {
    auto placement = item.value<Placement>();
    auto placementArrayJson = toJson(*appState, placement);
    std::ranges::copy(placementArrayJson, std::back_inserter(map));
  }

  QJsonObject camera;
  camera.insert("position", QJsonArray {0, 0, 30});

  QJsonObject root;
  root.insert("map", map);
  root.insert("camera", camera);

  return root;
}

QVariant
ProjectStructure::parseLevel(const QJsonValue& json)
{
  auto root = json.toObject();
  checkRequiredKey(root, "map");
  checkArray(root, "map");
  auto map = root.value("map").toArray();
  std::unordered_map<QString, Placement> placementBuffer;
  for (const auto& item : map) {
    auto jsonPlacement = item.toObject();
    checkRequiredKey(jsonPlacement, "entity_id");
    checkString(jsonPlacement, "entity_id");
    auto id = jsonPlacement.value("entity_id").toString();
    checkRequiredKey(jsonPlacement, "position");
    checkArray(jsonPlacement, "position");
    auto pos = jsonPlacement.value("position").toArray();
    const QVector3D position(pos.at(0).toDouble(), pos.at(1).toDouble(), pos.at(2).toDouble());
    if (placementBuffer.contains(id)) {
      placementBuffer[id].pushPosition(position);
    } else {
      Placement placement;
      placement.setId(id);
      placement.setBehaviour("static");
      placement.pushPosition(position);
      placementBuffer[id] = placement;
    }
  }
  QVariantMap result;
  for (const auto& [id, placement] : placementBuffer) {
    result[id] = QVariant::fromValue(placement);
  }
  return result;
}
