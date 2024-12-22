#include <QJsonObject>

#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "positionstrategysingle.h"

QString
PositionStrategySingle::entityId() const
{
  return m_entityId;
}

void
PositionStrategySingle::setEntityId(const QString& value)
{
  m_entityId = value;
}

QString
PositionStrategySingle::behaviour() const
{
  return m_behaviour;
}

void
PositionStrategySingle::setBehaviour(const QString& value)
{
  m_behaviour = value;
}

QVector3D
PositionStrategySingle::position() const
{
  return m_position;
}

void
PositionStrategySingle::setPosition(const QVector3D& value)
{
  m_position = value;
}

PositionStrategySingleFactory::PositionStrategySingleFactory(QObject *parent)
  : QObject(parent)
{
}

PositionStrategySingle
PositionStrategySingleFactory::create()
{
  return {};
}

QJsonObject
PositionStrategySingleFactory::toJson(const PositionStrategySingle &strategy)
{
  QJsonObject json;
  json["kind"] = "single";
  json["behaviour"] = strategy.behaviour();
  json["entity_id"] = strategy.entityId();
  json["position"] = Json::to_array(strategy.position());
  return json;
}

PositionStrategySingle PositionStrategySingleFactory::fromJson(const QJsonObject &json)
{
  return JsonValidator(this, &json, "'Single' strategy")
    .handle<PositionStrategySingle>([](auto& check, auto& strategy) {
      strategy.setBehaviour(check.string("behaviour"));
      strategy.setEntityId(check.string("entity_id"));
      strategy.setPosition(check.vector3d("position"));
    });
}
