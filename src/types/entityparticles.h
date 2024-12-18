#pragma once
#include <QObject>
#include <QQmlEngine>

#include "entitybase.h"

class EntityParticles : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityParticles)

  Q_PROPERTY(QString model_id READ model_id WRITE set_model_id FINAL)
  Q_PROPERTY(double lifetime READ lifetime WRITE set_lifetime FINAL)
  Q_PROPERTY(double speed READ speed WRITE set_speed FINAL)
  Q_PROPERTY(int quantity READ quantity WRITE set_quantity FINAL)

  QString m_model_id {};
  double m_lifetime {0};
  double m_speed {0};
  int m_quantity {0};

public:
  EntityParticles() = default;

  [[nodiscard]] QString model_id() const;
  void set_model_id(const QString &value);

  [[nodiscard]] double lifetime() const;
  void set_lifetime(double value);

  [[nodiscard]] double speed() const;
  void set_speed(double value);

  [[nodiscard]] int quantity() const;
  void set_quantity(int value);

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
