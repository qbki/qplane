#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QQuick3DInstancing>
#include <QVector3D>

class PositionStrategyVoid
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(positionStrategyVoid)
  Q_PROPERTY(QString entity_id READ entity_id WRITE set_entity_id)
  Q_PROPERTY(QString behaviour READ behaviour WRITE set_behaviour)

  QString m_entity_id {};
  QString m_behaviour {};

public:
  PositionStrategyVoid() = default;

  [[nodiscard]] QString entity_id() const;
  void set_entity_id(const QString &value);

  [[nodiscard]] QString behaviour() const;
  void set_behaviour(const QString &value);
};

Q_DECLARE_METATYPE(PositionStrategyVoid)

class PositionStrategyVoidFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  PositionStrategyVoidFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE PositionStrategyVoid create();
  Q_INVOKABLE QJsonObject toJson(const PositionStrategyVoid& strategy);
  Q_INVOKABLE PositionStrategyVoid fromJson(const QJsonObject& json);
};
