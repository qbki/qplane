#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QVariant>

class EntityPropVelocity
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityPropVelocity)

  Q_PROPERTY(QVariant speed READ speed WRITE set_speed FINAL)
  Q_PROPERTY(QVariant acceleration READ acceleration WRITE set_acceleration FINAL)
  Q_PROPERTY(QVariant damping READ damping WRITE set_damping FINAL)

  QVariant m_speed {};
  QVariant m_acceleration {};
  QVariant m_damping {};

public:
  EntityPropVelocity() = default;

  QVariant speed() const;
  void set_speed(const QVariant &newSpeed);

  QVariant acceleration() const;
  void set_acceleration(const QVariant &newAcceleration);

  QVariant damping() const;
  void set_damping(const QVariant &newDamping);
};

Q_DECLARE_METATYPE(EntityPropVelocity)

class EntityPropVelocityFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityPropVelocityFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityPropVelocity create();
  Q_INVOKABLE QJsonObject toJson(const EntityPropVelocity& entity);
  Q_INVOKABLE EntityPropVelocity fromJson(const QJsonObject& json);
};
