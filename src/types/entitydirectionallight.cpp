#include <QJsonObject>
#include <QJsonArray>

#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "entitydirectionallight.h"

QString
EntityDirectionalLight::id() const
{
  return m_id;
}

void
EntityDirectionalLight::set_id(const QString &value)
{
  m_id = value;
}

QColor
EntityDirectionalLight::color() const
{
  return m_color;
}

void
EntityDirectionalLight::set_color(const QColor &value)
{
  m_color = value;
}

QVector3D
EntityDirectionalLight::direction() const
{
  return m_direction;
}

void
EntityDirectionalLight::set_direction(const QVector3D &value)
{
  m_direction = value;
}

EntityDirectionalLightFactory::EntityDirectionalLightFactory(QObject *parent)
  : QObject(parent)
{
}

EntityDirectionalLight
EntityDirectionalLightFactory::create()
{
  return {};
}

QJsonObject
EntityDirectionalLightFactory::toJson(const EntityDirectionalLight &entity)
{
  QJsonObject json;
  json["kind"] = "directional_light";
  auto color = entity.color();
  json["color"] = QJsonArray {color.redF(), color.greenF(), color.blueF()};
  json["direction"] = Json::to_array(entity.direction());
  return json;
}

EntityDirectionalLight
EntityDirectionalLightFactory::fromJson(const QString &id, const QJsonObject &json)
{
  JsonValidator check(this, &json);
  EntityDirectionalLight entity;
  try {
    entity.set_id(id);
    entity.set_color(check.color("color"));
    entity.set_direction(check.vector3d("direction"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
