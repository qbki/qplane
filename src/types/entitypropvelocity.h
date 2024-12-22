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

  Q_PROPERTY(QVariant speed READ speed WRITE setSpeed FINAL)
  Q_PROPERTY(QVariant acceleration READ acceleration WRITE setAcceleration FINAL)
  Q_PROPERTY(QVariant damping READ damping WRITE setDamping FINAL)

  QVariant m_speed {};
  QVariant m_acceleration {};
  QVariant m_damping {};

public:
  EntityPropVelocity() = default;

  [[nodiscard]] QVariant speed() const;
  void setSpeed(const QVariant& value);

  [[nodiscard]] QVariant acceleration() const;
  void setAcceleration(const QVariant& value);

  [[nodiscard]] QVariant damping() const;
  void setDamping(const QVariant& value);
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
