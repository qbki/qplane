#include "src/utils/jsonvalidator.h"

#include "entitypropvelocity.h"

QVariant EntityPropVelocity::speed() const
{
  return m_speed;
}

void EntityPropVelocity::set_speed(const QVariant &value)
{
  m_speed = value;
}

QVariant EntityPropVelocity::acceleration() const
{
  return m_acceleration;
}

void EntityPropVelocity::set_acceleration(const QVariant &value)
{
  m_acceleration = value;
}

QVariant EntityPropVelocity::damping() const
{
  return m_damping;
}

void EntityPropVelocity::set_damping(const QVariant &value)
{
  m_damping = value;
}

EntityPropVelocityFactory::EntityPropVelocityFactory(QObject *parent)
  : QObject(parent)
{
}

EntityPropVelocity EntityPropVelocityFactory::create()
{
  return {};
}

QJsonObject EntityPropVelocityFactory::toJson(const EntityPropVelocity &entity)
{
  QJsonObject json;
  if (entity.speed().toJsonValue().isDouble()) {
    json["speed"] = entity.speed().toDouble();
  }
  if (entity.acceleration().toJsonValue().isDouble()) {
    json["acceleration"] = entity.acceleration().toDouble();
  }
  if (entity.damping().toJsonValue().isDouble()) {
    json["damping"] = entity.damping().toDouble();
  }
  return json;
}

EntityPropVelocity EntityPropVelocityFactory::fromJson(const QJsonObject &json)
{
  return JsonValidator(this, &json, "Velocity property")
    .handle<EntityPropVelocity>([&](auto& check, auto& entity) {
      entity.set_acceleration(check.optionalReal("acceleration", {}));
      entity.set_speed(check.optionalReal("speed", {}));
      entity.set_damping(check.optionalReal("damping", {}));
    });
}
