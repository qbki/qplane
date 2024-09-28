#include <QDir>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entityweapon.h"

QString EntityWeapon::id() const
{
  return m_id;
}

void EntityWeapon::set_id(const QString &value)
{
  m_id = value;
}

double EntityWeapon::projectile_speed() const
{
  return m_projectile_speed;
}

void EntityWeapon::set_projectile_speed(double value)
{
  m_projectile_speed = value;
}

double EntityWeapon::fire_rate() const
{
  return m_fire_rate;
}

void EntityWeapon::set_fire_rate(double value)
{
  m_fire_rate = value;
}

double EntityWeapon::lifetime() const
{
  return m_lifetime;
}

void EntityWeapon::set_lifetime(double value)
{
  m_lifetime = value;
}

double EntityWeapon::spread() const
{
  return m_spread;
}

void EntityWeapon::set_spread(double value)
{
  m_spread = value;
}

QString EntityWeapon::projectile_model_id() const
{
  return m_projectile_model_id;
}

void EntityWeapon::set_projectile_model_id(const QString &value)
{
  m_projectile_model_id = value;
}

QUrl EntityWeapon::shot_sound_path() const
{
  return m_shot_sound_path;
}

void EntityWeapon::set_shot_sound_path(const QUrl &value)
{
  m_shot_sound_path = value;
}

EntityWeaponFactory::EntityWeaponFactory(QObject *parent)
  : QObject(parent)
{
}

EntityWeapon EntityWeaponFactory::create()
{
  return {};
}

QJsonObject EntityWeaponFactory::toJson(const EntityWeapon &entity, const QUrl &projectDir)
{
  QJsonObject json;
  QDir dir(projectDir.toLocalFile());
  json["kind"] = "weapon";
  json["bullet_model_id"] = entity.projectile_model_id();
  json["bullet_speed"] = entity.projectile_speed();
  json["fire_rate"] = entity.fire_rate();
  json["lifetime"] = entity.lifetime();
  json["shot_sound_path"] = dir.relativeFilePath(entity.shot_sound_path().toLocalFile());
  json["spread"] = entity.spread();
  return json;
}

EntityWeapon EntityWeaponFactory::fromJson(const QString &id, const QJsonObject &json, const QUrl &projectDir)
{
  JsonValidator check(this, &json);
  const auto toUrl = [&](const QString& v) { return projectDir.resolved(v); };
  EntityWeapon entity;
  try {
    entity.set_id(id);
    entity.set_projectile_model_id(check.string("bullet_model_id"));
    entity.set_projectile_speed(check.real("bullet_speed"));
    entity.set_fire_rate(check.real("fire_rate"));
    entity.set_lifetime(check.real("lifetime"));
    entity.set_shot_sound_path(toUrl(check.string("shot_sound_path")));
    entity.set_spread(check.real("spread"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
