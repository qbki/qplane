#include <QDir>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entityweapon.h"

double
EntityWeapon::projectileSpeed() const
{
  return m_projectileSpeed;
}

void
EntityWeapon::setProjectileSpeed(double value)
{
  m_projectileSpeed = value;
}

double
EntityWeapon::fireRate() const
{
  return m_fireRate;
}

void
EntityWeapon::setFireRate(double value)
{
  m_fireRate = value;
}

double
EntityWeapon::lifetime() const
{
  return m_lifetime;
}

void
EntityWeapon::setLifetime(double value)
{
  m_lifetime = value;
}

double
EntityWeapon::spread() const
{
  return m_spread;
}

void
EntityWeapon::setSpread(double value)
{
  m_spread = value;
}

QString
EntityWeapon::projectileModelId() const
{
  return m_projectileModelId;
}

void
EntityWeapon::setProjectileModelId(const QString& value)
{
  m_projectileModelId = value;
}

QUrl
EntityWeapon::shotSoundPath() const
{
  return m_shotSoundPath;
}

void
EntityWeapon::setShotSoundPath(const QUrl& value)
{
  m_shotSoundPath = value;
}

EntityWeapon
EntityWeapon::copy() const
{
  return *this;
}

EntityWeaponFactory::EntityWeaponFactory(QObject* parent)
  : QObject(parent)
{
}

EntityWeapon
EntityWeaponFactory::create()
{
  return {};
}

QJsonObject
EntityWeaponFactory::toJson(const EntityWeapon& entity, const QUrl& projectDir)
{
  QJsonObject json;
  QDir dir(projectDir.toLocalFile());
  json["kind"] = "weapon";
  json["bullet_model_id"] = entity.projectileModelId();
  json["bullet_speed"] = entity.projectileSpeed();
  json["fire_rate"] = entity.fireRate();
  json["lifetime"] = entity.lifetime();
  json["name"] = entity.name();
  if (entity.shotSoundPath().isValid()) {
    json["shot_sound_path"] = dir.relativeFilePath(entity.shotSoundPath().toLocalFile());
  }
  json["spread"] = entity.spread();
  return json;
}

EntityWeapon
EntityWeaponFactory::fromJson(const QString& id, const QJsonObject& json, const QUrl& projectDir)
{
  const auto toUrl = [&](const QString& v) { return projectDir.resolved(v); };
  return JsonValidator(this, &json, id)
    .handle<EntityWeapon>([&](const JsonValidator& check, EntityWeapon& entity) {
      entity.setId(id);
      entity.setName(check.string("name"));
      entity.setFireRate(check.real("fire_rate"));
      entity.setLifetime(check.real("lifetime"));
      entity.setProjectileModelId(check.string("bullet_model_id"));
      entity.setProjectileSpeed(check.real("bullet_speed"));
      entity.setSpread(check.real("spread"));

      auto shot_sound_path_source = check.optionalString("shot_sound_path", "");
      auto shot_sound_path = shot_sound_path_source == "" ? QUrl() : toUrl(shot_sound_path_source);
      entity.setShotSoundPath(shot_sound_path);
    });
}
