#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QString>

#include "entitybase.h"
#include "entitypropvelocity.h"

class EntityActor : public EntityBase
{
  Q_GADGET
  QML_NAMED_ELEMENT(entityActor)
  Q_PROPERTY(QString modelId READ modelId WRITE setModelId FINAL)
  Q_PROPERTY(QString weaponId READ weaponId WRITE setWeaponId FINAL)
  Q_PROPERTY(QString hitParticlesId READ hitParticlesId WRITE setHitParticlesId FINAL)
  Q_PROPERTY(QString debrisId READ debrisId WRITE setDebrisId FINAL)
  Q_PROPERTY(int lives READ lives WRITE setLives FINAL)
  Q_PROPERTY(EntityPropVelocity speed READ speed WRITE setSpeed FINAL)

public:
  EntityActor() = default;

  [[nodiscard]] QString modelId() const;
  void setModelId(const QString& value);

  [[nodiscard]] QString weaponId() const;
  void setWeaponId(const QString& value);

  [[nodiscard]] QString hitParticlesId() const;
  void setHitParticlesId(const QString& value);

  [[nodiscard]] QString debrisId() const;
  void setDebrisId(const QString& value);

  [[nodiscard]] EntityPropVelocity speed() const;
  void setSpeed(const EntityPropVelocity& value);

  [[nodiscard]] int lives() const;
  void setLives(int value);

  [[nodiscard]] Q_INVOKABLE EntityActor copy() const;

private:
  QString m_modelId {};
  QString m_weaponId {};
  QString m_hitParticlesId {};
  QString m_debrisId {};
  EntityPropVelocity m_speed {};
  int m_lives {1};
};

Q_DECLARE_METATYPE(EntityActor)

class EntityActorFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityActorFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityActor create();
  Q_INVOKABLE QJsonObject toJson(const EntityActor& entity);
  Q_INVOKABLE EntityActor fromJson(const QString& id, const QJsonObject& json);
};
