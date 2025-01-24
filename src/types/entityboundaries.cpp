#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "entityboundaries.h"

EntityBoundaries::EntityBoundaries(QVector3D min, QVector3D max)
  : m_min(min)
  , m_max(max)
{
}

QVector3D
EntityBoundaries::min() const
{
  return m_min;
}

void
EntityBoundaries::setMin(const QVector3D& value)
{
  m_min = value;
}

QVector3D
EntityBoundaries::max() const
{
  return m_max;
}

void
EntityBoundaries::setMax(const QVector3D& value)
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
    entity.setMin(check.vector3d("min"));
    entity.setMax(check.vector3d("max"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
