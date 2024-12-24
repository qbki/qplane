#include "src/utils/jsonvalidator.h"
#include "src/utils/jssetter.h"

#include "entitypropvelocity.h"


QJSValue
EntityPropVelocity::speed() const
{
  return m_speed;
}

void
EntityPropVelocity::setSpeed(const QJSValue& value)
{
  m_speed = JSStrictSetter(__func__, value, QJSValue::NullValue)
    .nullable()
    .number()
    .value();
}

QJSValue
EntityPropVelocity::acceleration() const
{
  return m_acceleration;
}

void
EntityPropVelocity::setAcceleration(const QJSValue& value)
{
  m_acceleration = JSStrictSetter(__func__, value, QJSValue::NullValue)
    .nullable()
    .number()
    .value();
}

QJSValue
EntityPropVelocity::damping() const
{
  return m_damping;
}

void
EntityPropVelocity::setDamping(const QJSValue& value)
{
  m_damping = JSStrictSetter(__func__, value, QJSValue::NullValue)
    .nullable()
    .number()
    .value();
}

EntityPropVelocityFactory::EntityPropVelocityFactory(QObject* parent)
  : QObject(parent)
{
}

EntityPropVelocity
EntityPropVelocityFactory::create()
{
  return {};
}

QJsonObject
EntityPropVelocityFactory::toJson(const EntityPropVelocity& entity)
{
  QJsonObject json;
  if (entity.speed().isNumber()) {
    json["speed"] = entity.speed().toNumber();
  }
  if (entity.acceleration().isNumber()) {
    json["acceleration"] = entity.acceleration().toNumber();
  }
  if (entity.damping().isNumber()) {
    json["damping"] = entity.damping().toNumber();
  }
  return json;
}

EntityPropVelocity
EntityPropVelocityFactory::fromJson(const QJsonObject& json)
{
  return JsonValidator(this, &json, "Velocity property")
    .handle<EntityPropVelocity>([&](auto& check, auto& entity) {
      entity.setAcceleration(check.optionalReal("acceleration", QJSValue {QJSValue::NullValue}));
      entity.setSpeed(check.optionalReal("speed", QJSValue {QJSValue::NullValue}));
      entity.setDamping(check.optionalReal("damping", QJSValue {QJSValue::NullValue}));
    });
}
