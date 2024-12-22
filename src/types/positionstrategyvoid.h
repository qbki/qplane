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
  Q_PROPERTY(QString entityId READ entityId WRITE setEntityId)
  Q_PROPERTY(QString behaviour READ behaviour WRITE setBehaviour)

  QString m_entityId {};
  QString m_behaviour {};

public:
  PositionStrategyVoid() = default;

  [[nodiscard]] QString entityId() const;
  void setEntityId(const QString& value);

  [[nodiscard]] QString behaviour() const;
  void setBehaviour(const QString& value);
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
