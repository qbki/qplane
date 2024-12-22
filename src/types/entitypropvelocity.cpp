#include "src/utils/jsonvalidator.h"

#include "entitypropvelocity.h"

QVariant EntityPropVelocity::speed() const
{
  return m_speed;
}

void EntityPropVelocity::setSpeed(const QVariant &value)
{
  Q_ASSERT_X(value.isNull() || (value.typeId() == QVariant(0.0).typeId()),
             "EntityPropVelocity::set_speed",
             "value must be null or double type");
  m_speed = value;
}

QVariant EntityPropVelocity::acceleration() const
{
  return m_acceleration;
}

void EntityPropVelocity::setAcceleration(const QVariant &value)
{
  Q_ASSERT_X(value.isNull() || (value.typeId() == QVariant(0.0).typeId()),
             "EntityPropVelocity::set_acceleration",
             "value must be null or double type");
  m_acceleration = value;
}

QVariant EntityPropVelocity::damping() const
{
  return m_damping;
}

void EntityPropVelocity::setDamping(const QVariant &value)
{
  Q_ASSERT_X(value.isNull() || (value.typeId() == QVariant(0.0).typeId()),
             "EntityPropVelocity::set_damping",
             "value must be null or double type");
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
      entity.setAcceleration(check.optionalReal("acceleration", {}));
      entity.setSpeed(check.optionalReal("speed", {}));
      entity.setDamping(check.optionalReal("damping", {}));
    });
}
