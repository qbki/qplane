#include <QJsonObject>
#include <QJsonArray>

#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "entitydirectionallight.h"

QColor
EntityDirectionalLight::color() const
{
  return m_color;
}

void
EntityDirectionalLight::setColor(const QColor& value)
{
  m_color = value;
}

QVector3D
EntityDirectionalLight::direction() const
{
  return m_direction;
}

void
EntityDirectionalLight::setDirection(const QVector3D& value)
{
  m_direction = value;
}

EntityDirectionalLight EntityDirectionalLight::copy() const
{
  return *this;
}

EntityDirectionalLightFactory::EntityDirectionalLightFactory(QObject* parent)
  : QObject(parent)
{
}

EntityDirectionalLight
EntityDirectionalLightFactory::create()
{
  return {};
}

QJsonObject
EntityDirectionalLightFactory::toJson(const EntityDirectionalLight& entity)
{
  auto color = entity.color();
  QJsonObject json;
  json["kind"] = "directional_light";
  json["name"] = entity.name();
  json["color"] = QJsonArray {color.redF(), color.greenF(), color.blueF()};
  json["direction"] = Json::to_array(entity.direction());
  return json;
}

EntityDirectionalLight
EntityDirectionalLightFactory::fromJson(const QString& id, const QJsonObject& json)
{
  return JsonValidator(this, &json, id)
    .handle<EntityDirectionalLight>([&](auto& check, auto& entity) {
      entity.setId(id);
      entity.setName(check.string("name"));
      entity.setColor(check.color("color"));
      entity.setDirection(check.vector3d("direction"));
    });
}
