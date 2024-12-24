#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>

class EntityPropVelocity
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityPropVelocity)

  Q_PROPERTY(QJSValue speed READ speed WRITE setSpeed FINAL)
  Q_PROPERTY(QJSValue acceleration READ acceleration WRITE setAcceleration FINAL)
  Q_PROPERTY(QJSValue damping READ damping WRITE setDamping FINAL)

  QJSValue m_speed {QJSValue::NullValue};
  QJSValue m_acceleration {QJSValue::NullValue};
  QJSValue m_damping {QJSValue::NullValue};

public:
  EntityPropVelocity() = default;

  [[nodiscard]] QJSValue speed() const;
  void setSpeed(const QJSValue& value);

  [[nodiscard]] QJSValue acceleration() const;
  void setAcceleration(const QJSValue& value);

  [[nodiscard]] QJSValue damping() const;
  void setDamping(const QJSValue& value);
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
