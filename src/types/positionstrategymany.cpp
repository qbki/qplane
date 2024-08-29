#include <QJsonArray>
#include <QJsonObject>
#include <QVector3D>

#include "src/utils/jsonvalidator.h"

#include "positionstrategymany.h"

PositionStrategyMany::PositionStrategyMany()
{
}

QString PositionStrategyMany::entity_id() const
{
  return m_entity_id;
}

void PositionStrategyMany::set_entity_id(const QString &new_entity_id)
{
  m_entity_id = new_entity_id;
}

QString PositionStrategyMany::behaviour() const
{
  return m_behaviour;
}

void PositionStrategyMany::set_behaviour(const QString &new_behaviour)
{
  m_behaviour = new_behaviour;
}

QVariantList PositionStrategyMany::positions() const
{
  return m_positions;
}

void PositionStrategyMany::set_positions(const QVariantList &new_positions)
{
  m_positions = new_positions;
}

PositionStrategyManyFactory::PositionStrategyManyFactory(QObject *parent)
  : QObject(parent)
{
}

PositionStrategyMany PositionStrategyManyFactory::create()
{
  return {};
}

QJsonObject PositionStrategyManyFactory::toJson(const PositionStrategyMany &strategy)
{
  QJsonObject json;
  json["kind"] = "many";
  json["behaviour"] = strategy.behaviour();
  json["entity_id"] = strategy.entity_id();
  QJsonArray positions;
  for (const auto& variant : strategy.positions()) {
    QVector3D vector = variant.value<QVector3D>();
    positions.push_back(vector.x());
    positions.push_back(vector.y());
    positions.push_back(vector.z());
  }
  json["positions"] = positions;
  return json;
}

PositionStrategyMany PositionStrategyManyFactory::fromJson(const QJsonObject &json)
{
  JsonValidator check(this, &json);
  PositionStrategyMany strategy;
  try {
    strategy.set_behaviour(check.string("behaviour"));
    strategy.set_entity_id(check.string("entity_id"));
    strategy.set_positions(check.vectors3d("positions"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return strategy;
}
