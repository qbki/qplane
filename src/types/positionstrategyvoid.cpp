#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "positionstrategyvoid.h"

QString
PositionStrategyVoid::entity_id() const
{
  return m_entity_id;
}

void
PositionStrategyVoid::set_entity_id(const QString &value)
{
  m_entity_id = value;
}

QString
PositionStrategyVoid::behaviour() const
{
  return m_behaviour;
}

void
PositionStrategyVoid::set_behaviour(const QString &value)
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
  json["entity_id"] = strategy.entity_id();
  return json;
}

PositionStrategyVoid
PositionStrategyVoidFactory::fromJson(const QJsonObject &json)
{
  return JsonValidator(this, &json, "'Void' strategy")
    .handle<PositionStrategyVoid>([](auto& check, auto& strategy) {
      strategy.set_behaviour(check.string("behaviour"));
      strategy.set_entity_id(check.string("entity_id"));
    });
}
