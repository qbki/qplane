#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QQuick3DInstancing>
#include <QVector3D>

class PositionStrategyMany
{
  Q_GADGET
  Q_PROPERTY(QString entity_id READ entity_id WRITE set_entity_id)
  Q_PROPERTY(QString behaviour READ behaviour WRITE set_behaviour)
  Q_PROPERTY(QVariantList positions READ positions WRITE set_positions)
  QML_NAMED_ELEMENT(positionStrategyMany)

public:
  PositionStrategyMany();

  QString entity_id() const;
  void set_entity_id(const QString &newEntity_id);

  QString behaviour() const;
  void set_behaviour(const QString &newBehaviour);

  QVariantList positions() const;
  void set_positions(const QVariantList &newPositions);

private:
  QString m_entity_id;
  QString m_behaviour;
  QVariantList m_positions;
};

Q_DECLARE_METATYPE(PositionStrategyMany)

class PositionStrategyManyFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  PositionStrategyManyFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE PositionStrategyMany create();

  Q_INVOKABLE QJsonObject toJson(const PositionStrategyMany& strategy);
  Q_INVOKABLE PositionStrategyMany fromJson(const QJsonObject& json);
};
