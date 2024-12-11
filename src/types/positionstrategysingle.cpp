#include <QJsonObject>

#include "src/utils/json.h"
#include "src/utils/jsonvalidator.h"

#include "positionstrategysingle.h"

QString
PositionStrategySingle::entity_id() const
{
  return m_entity_id;
}

void
PositionStrategySingle::set_entity_id(const QString &value)
{
  m_entity_id = value;
}

QString
PositionStrategySingle::behaviour() const
{
  return m_behaviour;
}

void
PositionStrategySingle::set_behaviour(const QString &value)
{
  m_behaviour = value;
}

QVector3D
PositionStrategySingle::position() const
{
  return m_position;
}

void
PositionStrategySingle::set_position(const QVector3D &value)
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
  json["entity_id"] = strategy.entity_id();
  json["position"] = Json::to_array(strategy.position());
  return json;
}

PositionStrategySingle PositionStrategySingleFactory::fromJson(const QJsonObject &json)
{
  return JsonValidator(this, &json, "'Single' strategy")
    .handle<PositionStrategySingle>([](auto& check, auto& strategy) {
      strategy.set_behaviour(check.string("behaviour"));
      strategy.set_entity_id(check.string("entity_id"));
      strategy.set_position(check.vector3d("position"));
    });
}
