#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "positionstrategyvoid.h"

QString
PositionStrategyVoid::entityId() const
{
  return m_entityId;
}

void
PositionStrategyVoid::setEntityId(const QString& value)
{
  m_entityId = value;
}

QString
PositionStrategyVoid::behaviour() const
{
  return m_behaviour;
}

void
PositionStrategyVoid::setBehaviour(const QString& value)
{
  m_behaviour = value;
}

PositionStrategyVoidFactory::PositionStrategyVoidFactory(QObject *parent)
  : QObject(parent)
{
}

PositionStrategyVoid
PositionStrategyVoidFactory::create()
{
  return {};
}

QJsonObject
PositionStrategyVoidFactory::toJson(const PositionStrategyVoid &strategy)
{
  QJsonObject json;
  json["kind"] = "void";
  json["behaviour"] = strategy.behaviour();
  json["entity_id"] = strategy.entityId();
  return json;
}

PositionStrategyVoid
PositionStrategyVoidFactory::fromJson(const QJsonObject &json)
{
  return JsonValidator(this, &json, "'Void' strategy")
    .handle<PositionStrategyVoid>([](auto& check, auto& strategy) {
      strategy.setBehaviour(check.string("behaviour"));
      strategy.setEntityId(check.string("entity_id"));
    });
}
