#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QString>

class EntityActor
{
  Q_GADGET
  QML_NAMED_ELEMENT(entityActor)

  Q_PROPERTY(QString id READ id WRITE set_id FINAL)
  Q_PROPERTY(QString model_id READ model_id WRITE set_model_id FINAL)
  Q_PROPERTY(QString gun_id READ gun_id WRITE set_gun_id FINAL)
  Q_PROPERTY(QString hit_particles_id READ hit_particles_id WRITE set_hit_particles_id FINAL)
  Q_PROPERTY(QString debris_id READ debris_id WRITE set_debris_id FINAL)
  Q_PROPERTY(float speed READ speed WRITE set_speed FINAL)

public:
  EntityActor();

  QString id() const;
  void set_id(const QString &new_id);

  QString model_id() const;
  void set_model_id(const QString &new_model_id);

  QString gun_id() const;
  void set_gun_id(const QString &new_gun_id);

  QString hit_particles_id() const;
  void set_hit_particles_id(const QString &new_hit_particles_id);

  QString debris_id() const;
  void set_debris_id(const QString &new_debris_id);

  float speed() const;
  void set_speed(float new_speed);

private:
  QString m_id = "";
  QString m_model_id = "";
  QString m_gun_id = "";
  QString m_hit_particles_id = "";
  QString m_debris_id = "";
  float m_speed = 0;
};

Q_DECLARE_METATYPE(EntityActor)

class EntityActorFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityActorFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityActor create();
  Q_INVOKABLE QJsonObject toJson(const EntityActor& entity);
  Q_INVOKABLE EntityActor fromJson(const QString& id, const QJsonObject& json);
};
