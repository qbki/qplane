#pragma once
#include <QObject>
#include <QVector3D>
#include <qqmlregistration.h>

class PositionStrategySingle
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(positionStrategySingle)
  Q_PROPERTY(QString entity_id READ entity_id WRITE set_entity_id)
  Q_PROPERTY(QString behaviour READ behaviour WRITE set_behaviour)
  Q_PROPERTY(QVector3D position READ position WRITE set_position)

  QString m_entity_id;
  QString m_behaviour;
  QVector3D m_position;

public:
  PositionStrategySingle() = default;

  [[nodiscard]] QString entity_id() const;
  void set_entity_id(const QString &value);

  [[nodiscard]] QString behaviour() const;
  void set_behaviour(const QString &value);

  [[nodiscard]] QVector3D position() const;
  void set_position(const QVector3D &value);
};

Q_DECLARE_METATYPE(PositionStrategySingle)

class PositionStrategySingleFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  PositionStrategySingleFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE PositionStrategySingle create();
  Q_INVOKABLE QJsonObject toJson(const PositionStrategySingle& strategy);
  Q_INVOKABLE PositionStrategySingle fromJson(const QJsonObject& json);
};
