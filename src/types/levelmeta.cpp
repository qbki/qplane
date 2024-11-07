#include "src/utils/jsonvalidator.h"
#include "src/utils/utils.h"

#include "levelmeta.h"

EntityCamera LevelMeta::camera() const
{
  return m_camera;
}

void LevelMeta::set_camera(const EntityCamera &value)
{
  m_camera = value;
}

EntityBoundaries LevelMeta::boundaries() const
{
  return m_boundaries;
}

void LevelMeta::set_boundaries(const EntityBoundaries &value)
{
  m_boundaries = value;
}

LevelMetaFactory::LevelMetaFactory(QObject *parent)
  : QObject(parent)
{
}

LevelMeta
LevelMetaFactory::create()
{
  return {};
}

QJsonObject
LevelMetaFactory::toJson(const LevelMeta &entity)
{
  QJsonObject json;
  auto& cameraFactory = getQmlSingleton<EntityCameraFactory>(this);
  auto& boundariesFactory = getQmlSingleton<EntityBoundariesFactory>(this);
  json["camera"] = cameraFactory.toJson(entity.camera());
  json["boundaries"] = boundariesFactory.toJson(entity.boundaries());
  return json;
}

LevelMeta
LevelMetaFactory::fromJson(const QJsonObject &json)
{
  JsonValidator check(this, &json);
  LevelMeta entity;
  try {
    auto& cameraFactory = getQmlSingleton<EntityCameraFactory>(this);
    auto& boundariesFactory = getQmlSingleton<EntityBoundariesFactory>(this);
    entity.set_camera(cameraFactory.fromJson(check.obj("camera")));
    entity.set_boundaries(boundariesFactory.fromJson(check.obj("boundaries")));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
