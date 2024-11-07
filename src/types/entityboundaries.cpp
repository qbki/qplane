#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "entityboundaries.h"

QVector3D
EntityBoundaries::min() const
{
  return m_min;
}

void
EntityBoundaries::set_min(const QVector3D &value)
{
  m_min = value;
}

QVector3D
EntityBoundaries::max() const
{
  return m_max;
}

void
EntityBoundaries::set_max(const QVector3D &value)
{
  m_max = value;
}

EntityBoundariesFactory::EntityBoundariesFactory(QObject *parent)
  : QObject(parent)
{
}

EntityBoundaries
EntityBoundariesFactory::create() const
{
  return {};
}

QJsonObject
EntityBoundariesFactory::toJson(const EntityBoundaries &entity) const
{
  QJsonObject json;
  json["min"] = Json::to_array(entity.min());
  json["max"] = Json::to_array(entity.max());
  return json;
}

EntityBoundaries
EntityBoundariesFactory::fromJson(const QJsonObject &json) const
{
  JsonValidator check(this, &json);
  EntityBoundaries entity;
  try {
    entity.set_min(check.vector3d("min"));
    entity.set_max(check.vector3d("max"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
