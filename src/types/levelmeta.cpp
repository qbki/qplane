#include "src/utils/jsonvalidator.h"
#include "src/utils/utils.h"

#include "levelmeta.h"

EntityCamera LevelMeta::camera() const
{
  return m_camera;
}

void LevelMeta::setCamera(const EntityCamera& value)
{
  m_camera = value;
}

EntityBoundaries LevelMeta::boundaries() const
{
  return m_boundaries;
}

void LevelMeta::setBoundaries(const EntityBoundaries& value)
{
  m_boundaries = value;
}

LevelMetaFactory::LevelMetaFactory(QObject* parent)
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
  auto& cameraFactory = getQmlSingleton<EntityCameraFactory>(this);
  auto& boundariesFactory = getQmlSingleton<EntityBoundariesFactory>(this);
  return JsonValidator(this, &json, "Meta")
    .handle<LevelMeta>([&](auto& check, auto& entity) {
      entity.setCamera(cameraFactory.fromJson(check.obj("camera")));
      entity.setBoundaries(boundariesFactory.fromJson(check.obj("boundaries")));
    });
}
