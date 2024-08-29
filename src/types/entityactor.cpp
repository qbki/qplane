#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entityactor.h"

EntityActor::EntityActor() {}

QString EntityActor::model_id() const
{
  return m_model_id;
}

void EntityActor::set_model_id(const QString &new_model_id)
{
  m_model_id = new_model_id;
}

QString EntityActor::gun_id() const
{
  return m_gun_id;
}

void EntityActor::set_gun_id(const QString &new_gun_id)
{
  m_gun_id = new_gun_id;
}

QString EntityActor::hit_particles_id() const
{
  return m_hit_particles_id;
}

void EntityActor::set_hit_particles_id(const QString &new_hit_particles_id)
{
  m_hit_particles_id = new_hit_particles_id;
}

QString EntityActor::debris_id() const
{
  return m_debris_id;
}

void EntityActor::set_debris_id(const QString &new_debris_id)
{
  m_debris_id = new_debris_id;
}

float EntityActor::speed() const
{
  return m_speed;
}

void EntityActor::set_speed(float new_speed)
{
  m_speed = new_speed;
}


QString EntityActor::id() const
{
  return m_id;
}

void EntityActor::set_id(const QString &new_id)
{
  m_id = new_id;
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
  json["kind"] = "actor";
  json["model_id"] = entity.model_id();
  json["speed"] = entity.speed();
  if (auto value = entity.gun_id(); !value.isEmpty()) {
    json["gun_id"] = value;
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
  JsonValidator check(this, &json);
  EntityActor entity;
  try {
    entity.set_id(id);
    entity.set_debris_id(check.optionalString("debris_id", ""));
    entity.set_gun_id(check.optionalString("gun_id", ""));
    entity.set_hit_particles_id(check.optionalString("hit_particles_id", ""));
    entity.set_model_id(check.string("model_id"));
    entity.set_speed(check.real("speed"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
