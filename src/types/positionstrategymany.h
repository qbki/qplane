#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QQuick3DInstancing>
#include <QVector3D>

class PositionStrategyMany
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(positionStrategyMany)
  Q_PROPERTY(QString entity_id READ entity_id WRITE set_entity_id)
  Q_PROPERTY(QString behaviour READ behaviour WRITE set_behaviour)
  Q_PROPERTY(QVariantList positions READ positions WRITE set_positions)

  QString m_entity_id {};
  QString m_behaviour {};
  QVariantList m_positions {};

public:
  PositionStrategyMany() = default;

  [[nodiscard]] QString entity_id() const;
  void set_entity_id(const QString &newEntity_id);

  [[nodiscard]] QString behaviour() const;
  void set_behaviour(const QString &newBehaviour);

  [[nodiscard]] QVariantList positions() const;
  void set_positions(const QVariantList &newPositions);
};

Q_DECLARE_METATYPE(PositionStrategyMany)

class PositionStrategyManyFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  PositionStrategyManyFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE PositionStrategyMany create();
  Q_INVOKABLE QJsonObject toJson(const PositionStrategyMany& strategy);
  Q_INVOKABLE PositionStrategyMany fromJson(const QJsonObject& json);
};
