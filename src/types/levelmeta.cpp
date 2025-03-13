#include <QJsonArray>

#include "src/utils/jsonvalidator.h"
#include "src/utils/utils.h"

#include "levelmeta.h"

LevelMeta::LevelMeta()
{
  m_camera.setPosition({0, 0, DEFAULT_CAMERA_HEIGHT});
}

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

void
LevelMeta::setBoundaries(const EntityBoundaries& value)
{
  m_boundaries = value;
}

QList<LevelLayer>
LevelMeta::layers() const
{
  return m_layers;
}

void LevelMeta::setLayers(const QList<LevelLayer>& value)
{
  m_layers = value;
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
LevelMetaFactory::toJson(const LevelMeta& entity)
{
  QJsonObject json;
  auto& cameraFactory = getQmlSingleton<EntityCameraFactory>(this);
  auto& boundariesFactory = getQmlSingleton<EntityBoundariesFactory>(this);
  auto& levelLayerFactory = getQmlSingleton<LevelLayerFactory>(this);

  QJsonArray jsonLayers {};
  for (auto& layer : entity.layers()) {
    jsonLayers.push_back(levelLayerFactory.toJson(layer));
  }

  json["camera"] = cameraFactory.toJson(entity.camera());
  json["boundaries"] = boundariesFactory.toJson(entity.boundaries());
  json["layers"] = jsonLayers;

  return json;
}

LevelMeta
LevelMetaFactory::fromJson(const QJsonObject &json)
{
  auto& cameraFactory = getQmlSingleton<EntityCameraFactory>(this);
  auto& boundariesFactory = getQmlSingleton<EntityBoundariesFactory>(this);
  auto& levelLayerFactory = getQmlSingleton<LevelLayerFactory>(this);
  return JsonValidator(this, &json, "Meta")
    .handle<LevelMeta>([&](const JsonValidator& check, LevelMeta& entity) {
      entity.setCamera(cameraFactory.fromJson(check.obj("camera")));
      entity.setBoundaries(boundariesFactory.fromJson(check.obj("boundaries")));

      const auto jsonLayers = check.optionalArray("layers", {});
      QList<LevelLayer> layers;
      for (auto jsonLayer : jsonLayers) {
        auto obj = jsonLayer.toObject();
        layers.push_back(levelLayerFactory.fromJson(obj));
      }
      entity.setLayers(layers);
    });
}
