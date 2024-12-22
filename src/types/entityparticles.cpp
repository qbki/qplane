#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entityparticles.h"

QString
EntityParticles::modelId() const
{
  return m_modelId;
}

void
EntityParticles::setModelId(const QString& value)
{
  m_modelId = value;
}

double
EntityParticles::lifetime() const
{
  return m_lifetime;
}

void
EntityParticles::setLifetime(double value)
{
  m_lifetime = value;
}

int
EntityParticles::quantity() const
{
  return m_quantity;
}

void
EntityParticles::setQuantity(int value)
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
EntityParticles::setSpeed(double value)
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
  json["model_id"] = entity.modelId();
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
      entity.setId(id);
      entity.setName(check.string("name"));
      entity.setLifetime(check.real("lifetime"));
      entity.setModelId(check.string("model_id"));
      entity.setQuantity(static_cast<int>(check.real("quantity")));
      entity.setSpeed(check.real("speed"));
    });
}
