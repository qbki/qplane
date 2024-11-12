#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QString>

#include "entitypropvelocity.h"

class EntityActor
{
  Q_GADGET
  QML_NAMED_ELEMENT(entityActor)
  Q_PROPERTY(QString id READ id WRITE set_id FINAL)
  Q_PROPERTY(QString model_id READ model_id WRITE set_model_id FINAL)
  Q_PROPERTY(QString weapon_id READ weapon_id WRITE set_weapon_id FINAL)
  Q_PROPERTY(QString hit_particles_id READ hit_particles_id WRITE set_hit_particles_id FINAL)
  Q_PROPERTY(QString debris_id READ debris_id WRITE set_debris_id FINAL)
  Q_PROPERTY(int lives READ lives WRITE set_lives FINAL)
  Q_PROPERTY(EntityPropVelocity speed READ speed WRITE set_speed FINAL)

public:
  EntityActor() = default;

  QString id() const;
  void set_id(const QString &value);

  QString model_id() const;
  void set_model_id(const QString &value);

  QString weapon_id() const;
  void set_weapon_id(const QString &value);

  QString hit_particles_id() const;
  void set_hit_particles_id(const QString &value);

  QString debris_id() const;
  void set_debris_id(const QString &value);

  EntityPropVelocity speed() const;
  void set_speed(const EntityPropVelocity& value);

  int lives() const;
  void set_lives(int value);

  Q_INVOKABLE EntityActor copy() const;

private:
  QString m_id = "";
  QString m_model_id = "";
  QString m_weapon_id = "";
  QString m_hit_particles_id = "";
  QString m_debris_id = "";
  EntityPropVelocity m_speed {};
  int m_lives = 1;
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
