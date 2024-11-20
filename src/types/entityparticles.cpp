#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entityparticles.h"

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
  json["name"] = entity.name();
  json["quantity"] = entity.quantity();
  json["speed"] = entity.speed();
  return json;
}

EntityParticles
EntityParticlesFactory::fromJson(const QString &id, const QJsonObject &json)
{
  return JsonValidator(this, &json, id)
    .handle<EntityParticles>([&](auto& check, auto& entity) {
      entity.set_id(id);
      entity.set_lifetime(check.real("lifetime"));
      entity.set_model_id(check.string("model_id"));
      entity.set_name(check.string("name"));
      entity.set_quantity(static_cast<int>(check.real("quantity")));
      entity.set_speed(check.real("speed"));
    });
}
