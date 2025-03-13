#include <QJsonObject>

#include "src/utils/jsonvalidator.h"
#include "src/utils/utils.h"

#include "entityactor.h"

QString EntityActor::modelId() const
{
  return m_modelId;
}

void EntityActor::setModelId(const QString &value)
{
  m_modelId = value;
}

QString EntityActor::weaponId() const
{
  return m_weaponId;
}

void EntityActor::setWeaponId(const QString &value)
{
  m_weaponId = value;
}

QString EntityActor::hitParticlesId() const
{
  return m_hitParticlesId;
}

void EntityActor::setHitParticlesId(const QString &value)
{
  m_hitParticlesId = value;
}

QString EntityActor::debrisId() const
{
  return m_debrisId;
}

void EntityActor::setDebrisId(const QString &value)
{
  m_debrisId = value;
}

EntityPropVelocity EntityActor::speed() const
{
  return m_speed;
}

void EntityActor::setSpeed(const EntityPropVelocity& value)
{
  m_speed = value;
}

int EntityActor::lives() const
{
  return m_lives;
}

void EntityActor::setLives(int new_lives)
{
  m_lives = new_lives;
}

double EntityActor::rotationSpeed() const
{
  return m_rotationSpeed;
}

void EntityActor::setRotationSpeed(double value)
{
  m_rotationSpeed = value;
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
  json["model_id"] = entity.modelId();
  json["name"] = entity.name();
  json["rotation_speed"] = entity.rotationSpeed();
  json["speed"] = velocity.toJson(entity.speed()) ;
  if (auto value = entity.weaponId(); !value.isEmpty()) {
    json["weapon_id"] = value;
  }
  if (auto value = entity.debrisId(); !value.isEmpty()) {
    json["debris_id"] = value;
  }
  if (auto value = entity.hitParticlesId(); !value.isEmpty()) {
    json["hit_particles_id"] = value;
  }
  return json;
}

EntityActor EntityActorFactory::fromJson(const QString &id, const QJsonObject &json)
{
  return JsonValidator(this, &json, id)
    .handle<EntityActor>([&](const auto& check, auto& entity) {
      auto& velocity = getQmlSingleton<EntityPropVelocityFactory>(this);
      entity.setId(id);
      entity.setName(check.string("name"));
      entity.setDebrisId(check.optionalString("debris_id", ""));
      entity.setWeaponId(check.optionalString("weapon_id", ""));
      entity.setHitParticlesId(check.optionalString("hit_particles_id", ""));
      entity.setModelId(check.string("model_id"));
      entity.setSpeed(velocity.fromJson(check.obj("speed")));
      entity.setLives(static_cast<int>(check.real("lives")));
      entity.setRotationSpeed(check.optionalReal("rotation_speed", 0.f));
    });
}
