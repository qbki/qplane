#include <QJsonArray>
#include <QJsonObject>
#include <QVector3D>

#include "src/consts.h"
#include "src/utils/jsonvalidator.h"

#include "positionstrategymany.h"

QString
PositionStrategyMany::entityId() const
{
  return m_entityId;
}

void
PositionStrategyMany::setEntityId(const QString& value)
{
  m_entityId = value;
}

QString
PositionStrategyMany::behaviour() const
{
  return m_behaviour;
}

void
PositionStrategyMany::setBehaviour(const QString& value)
{
  m_behaviour = value;
}

QVariantList
PositionStrategyMany::positions() const
{
  return m_positions;
}

void
PositionStrategyMany::setPositions(const QVariantList& value)
{
  m_positions = value;
}

QString
PositionStrategyMany::layerId() const
{
  return m_layerId;
}

void
PositionStrategyMany::setLayerId(const QString& value)
{
  m_layerId = value;
}

PositionStrategyManyFactory::PositionStrategyManyFactory(QObject* parent)
  : QObject(parent)
{
}

PositionStrategyMany
PositionStrategyManyFactory::create()
{
  return {};
}

QJsonObject
PositionStrategyManyFactory::toJson(const PositionStrategyMany& strategy)
{
  QJsonObject json;
  json["kind"] = "many";
  json["behaviour"] = strategy.behaviour();
  json["entity_id"] = strategy.entityId();
  json["layer_id"] = strategy.layerId();
  QJsonArray positions;
  for (const auto& variant : static_cast<const QList<QVariant>>(strategy.positions())) {
    auto vector = variant.value<QVector3D>();
    positions.push_back(vector.x());
    positions.push_back(vector.y());
    positions.push_back(vector.z());
  }
  json["positions"] = positions;
  return json;
}

PositionStrategyMany
PositionStrategyManyFactory::fromJson(const QJsonObject& json)
{
  return JsonValidator(this, &json, "'Many' strategy")
    .handle<PositionStrategyMany>([](const JsonValidator& check, PositionStrategyMany& strategy) {
      strategy.setBehaviour(check.string("behaviour"));
      strategy.setEntityId(check.string("entity_id"));
      strategy.setLayerId(check.optionalString("layer_id", DEFAULT_SCENE_LAYER_ID));
      strategy.setPositions(check.vectors3d("positions"));
    });
}
