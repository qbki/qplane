#pragma once
#include <QObject>
#include <QVector3D>
#include <qqmlregistration.h>

class PositionStrategySingle
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(positionStrategySingle)
  Q_PROPERTY(QString entityId READ entityId WRITE setEntityId)
  Q_PROPERTY(QString behaviour READ behaviour WRITE setBehaviour)
  Q_PROPERTY(QVector3D position READ position WRITE setPosition)

  QString m_entityId;
  QString m_behaviour;
  QVector3D m_position;

public:
  PositionStrategySingle() = default;

  [[nodiscard]] QString entityId() const;
  void setEntityId(const QString &value);

  [[nodiscard]] QString behaviour() const;
  void setBehaviour(const QString &value);

  [[nodiscard]] QVector3D position() const;
  void setPosition(const QVector3D &value);
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
