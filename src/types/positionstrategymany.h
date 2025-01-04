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
  Q_PROPERTY(QString entityId READ entityId WRITE setEntityId)
  Q_PROPERTY(QString layerId READ layerId WRITE setLayerId)
  Q_PROPERTY(QString behaviour READ behaviour WRITE setBehaviour)
  Q_PROPERTY(QVariantList positions READ positions WRITE setPositions)

  QString m_entityId {};
  QString m_behaviour {};
  QVariantList m_positions {};

  QString m_layerId;

public:
  PositionStrategyMany() = default;

  [[nodiscard]] QString entityId() const;
  void setEntityId(const QString& value);

  [[nodiscard]] QString layerId() const;
  void setLayerId(const QString& value);

  [[nodiscard]] QString behaviour() const;
  void setBehaviour(const QString& value);

  [[nodiscard]] QVariantList positions() const;
  void setPositions(const QVariantList& value);
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
