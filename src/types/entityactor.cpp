#include <QJsonObject>

#include "src/utils/jsonvalidator.h"
#include "src/utils/utils.h"

#include "entityactor.h"

QString EntityActor::model_id() const
{
  return m_model_id;
}

void EntityActor::set_model_id(const QString &value)
{
  m_model_id = value;
}

QString EntityActor::weapon_id() const
{
  return m_weapon_id;
}

void EntityActor::set_weapon_id(const QString &value)
{
  m_weapon_id = value;
}

QString EntityActor::hit_particles_id() const
{
  return m_hit_particles_id;
}

void EntityActor::set_hit_particles_id(const QString &value)
{
  m_hit_particles_id = value;
}

QString EntityActor::debris_id() const
{
  return m_debris_id;
}

void EntityActor::set_debris_id(const QString &value)
{
  m_debris_id = value;
}

EntityPropVelocity EntityActor::speed() const
{
  return m_speed;
}

void EntityActor::set_speed(const EntityPropVelocity& value)
{
  m_speed = value;
}

int EntityActor::lives() const
{
  return m_lives;
}

void EntityActor::set_lives(int new_lives)
{
  m_lives = new_lives;
}

EntityActor EntityActor::copy() const
{
  return *this;
}

EntityActorFactory::EntityActorFactory(QObject *parent)
  : QObject(parent)
{
}

EntityActor EntityActorFactory::create()
{
  return {};
}

QJsonObject EntityActorFactory::toJson(const EntityActor &entity)
{
  QJsonObject json;
  auto& velocity = getQmlSingleton<EntityPropVelocityFactory>(this);
  json["kind"] = "actor";
  json["lives"] = entity.lives();
  json["model_id"] = entity.model_id();
  json["name"] = entity.name();
  json["speed"] = velocity.toJson(entity.speed()) ;
  if (auto value = entity.weapon_id(); !value.isEmpty()) {
    json["weapon_id"] = value;
  }
  if (auto value = entity.debris_id(); !value.isEmpty()) {
    json["debris_id"] = value;
  }
  if (auto value = entity.hit_particles_id(); !value.isEmpty()) {
    json["hit_particles_id"] = value;
  }
  return json;
}

EntityActor EntityActorFactory::fromJson(const QString &id, const QJsonObject &json)
{
  return JsonValidator(this, &json, id)
    .handle<EntityActor>([&](const auto& check, auto& entity) {
      auto& velocity = getQmlSingleton<EntityPropVelocityFactory>(this);
      entity.set_id(id);
      entity.set_name(check.string("name"));
      entity.set_debris_id(check.optionalString("debris_id", ""));
      entity.set_weapon_id(check.optionalString("weapon_id", ""));
      entity.set_hit_particles_id(check.optionalString("hit_particles_id", ""));
      entity.set_model_id(check.string("model_id"));
      entity.set_speed(velocity.fromJson(check.obj("speed")));
      entity.set_lives(static_cast<int>(check.real("lives")));
    });
}
