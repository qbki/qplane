#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "entitycamera.h"


QVector3D EntityCamera::position() const
{
  return m_position;
}

void EntityCamera::set_position(const QVector3D &value)
{
  m_position = value;
}

EntityCameraFactory::EntityCameraFactory(QObject *parent)
  : QObject(parent)
{
}

EntityCamera
EntityCameraFactory::create()
{
  return {};
}

QJsonObject
EntityCameraFactory::toJson(const EntityCamera &entity)
{
  QJsonObject json;
  json["position"] = Json::to_array(entity.position());
  return json;
}

EntityCamera
EntityCameraFactory::fromJson(const QJsonObject &json)
{
  JsonValidator check(this, &json);
  EntityCamera entity;
  try {
    entity.set_position(check.vector3d("position"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
