#pragma once
#include <QObject>
#include <QQmlEngine>

#include "entitybase.h"

class EntityParticles : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityParticles)

  Q_PROPERTY(QString modelId READ modelId WRITE setModelId FINAL)
  Q_PROPERTY(double lifetime READ lifetime WRITE setLifetime FINAL)
  Q_PROPERTY(double speed READ speed WRITE setSpeed FINAL)
  Q_PROPERTY(int quantity READ quantity WRITE setQuantity FINAL)

  QString m_modelId {};
  double m_lifetime {0};
  double m_speed {0};
  int m_quantity {0};

public:
  EntityParticles() = default;

  [[nodiscard]] QString modelId() const;
  void setModelId(const QString &value);

  [[nodiscard]] double lifetime() const;
  void setLifetime(double value);

  [[nodiscard]] double speed() const;
  void setSpeed(double value);

  [[nodiscard]] int quantity() const;
  void setQuantity(int value);

  [[nodiscard]] Q_INVOKABLE EntityParticles copy() const;
};

Q_DECLARE_METATYPE(EntityParticles)

class EntityParticlesFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityParticlesFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityParticles create();
  Q_INVOKABLE QJsonObject toJson(const EntityParticles& entity);
  Q_INVOKABLE EntityParticles fromJson(const QString& id, const QJsonObject& json);
};
