#include "src/utils/jsonvalidator.h"

#include "levellayer.h"

bool
LevelLayer::isVisible() const
{
  return m_isVisible;
}

void
LevelLayer::setIsVisible(bool value)
{
  m_isVisible = value;
}

LevelLayer
LevelLayer::copy() const
{
  return *this;
}

LevelLayerFactory::LevelLayerFactory(QObject* parent)
  : QObject(parent)
{
}

LevelLayer
LevelLayerFactory::create()
{
  return {};
}

QJsonObject
LevelLayerFactory::toJson(const LevelLayer& entity)
{
  QJsonObject json;
  json["id"] = entity.id();
  json["name"] = entity.name();
  json["is_visible"] = entity.isVisible();
  return json;
}

LevelLayer
LevelLayerFactory::fromJson(const QJsonObject& json)
{
  return JsonValidator(this, &json)
    .handle<LevelLayer>([&](const JsonValidator& check, LevelLayer& entity) {
      entity.setId(check.string("id"));
      entity.setName(check.string("name"));
      entity.setIsVisible(check.boolean("is_visible"));
    });
}
