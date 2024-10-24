#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entityparticles.h"

QString
EntityParticles::id() const
{
  return m_id;
}

void
EntityParticles::set_id(const QString &value)
{
  m_id = value;
}

QString
EntityParticles::model_id() const
{
  return m_model_id;
}

void
EntityParticles::set_model_id(const QString &value)
{
  m_model_id = value;
}

double
EntityParticles::lifetime() const
{
  return m_lifetime;
}

void
EntityParticles::set_lifetime(double value)
{
  m_lifetime = value;
}

int
EntityParticles::quantity() const
{
  return m_quantity;
}

void
EntityParticles::set_quantity(int value)
{
  m_quantity = value;
}

EntityParticles EntityParticles::copy() const
{
  return *this;
}

double
EntityParticles::speed() const
{
  return m_speed;
}

void
EntityParticles::set_speed(double value)
{
  m_speed = value;
}

EntityParticlesFactory::EntityParticlesFactory(QObject *parent)
  : QObject(parent)
{}

EntityParticles
EntityParticlesFactory::create()
{
  return {};
}

QJsonObject
EntityParticlesFactory::toJson(const EntityParticles &entity)
{
  QJsonObject json;
  json["kind"] = "particles";
  json["lifetime"] = entity.lifetime();
  json["model_id"] = entity.model_id();
  json["quantity"] = entity.quantity();
  json["speed"] = entity.speed();
  return json;
}

EntityParticles
EntityParticlesFactory::fromJson(const QString &id, const QJsonObject &json)
{
  JsonValidator check(this, &json);
  EntityParticles entity;
  try {
    entity.set_id(id);
    entity.set_lifetime(check.real("lifetime"));
    entity.set_model_id(check.string("model_id"));
    entity.set_quantity(check.real("quantity"));
    entity.set_speed(check.real("speed"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
