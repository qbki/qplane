#pragma once
#include <QQmlEngine>
#include <QString>
#include <QUrl>

#include "entitybase.h"

class EntityWeapon : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityWeapon)

  Q_PROPERTY(double projectile_speed READ projectile_speed WRITE set_projectile_speed FINAL)
  Q_PROPERTY(double fire_rate READ fire_rate WRITE set_fire_rate FINAL)
  Q_PROPERTY(double lifetime READ lifetime WRITE set_lifetime FINAL)
  Q_PROPERTY(double spread READ spread WRITE set_spread FINAL)
  Q_PROPERTY(QString projectile_model_id READ projectile_model_id WRITE set_projectile_model_id FINAL)
  Q_PROPERTY(QUrl shot_sound_path READ shot_sound_path WRITE set_shot_sound_path FINAL)

  double m_projectile_speed {0};
  double m_fire_rate {0};
  double m_lifetime {0};
  double m_spread {0};
  QString m_projectile_model_id {};
  QUrl m_shot_sound_path {};

public:
  EntityWeapon() = default;

  [[nodiscard]] double projectile_speed() const;
  void set_projectile_speed(double value);

  [[nodiscard]] double fire_rate() const;
  void set_fire_rate(double value);

  [[nodiscard]] double lifetime() const;
  void set_lifetime(double value);

  [[nodiscard]] double spread() const;
  void set_spread(double value);

  [[nodiscard]] QString projectile_model_id() const;
  void set_projectile_model_id(const QString &value);

  [[nodiscard]] QUrl shot_sound_path() const;
  void set_shot_sound_path(const QUrl &value);

  [[nodiscard]] Q_INVOKABLE EntityWeapon copy() const;
};

Q_DECLARE_METATYPE(EntityWeapon)

class EntityWeaponFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityWeaponFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityWeapon create();
  Q_INVOKABLE QJsonObject toJson(const EntityWeapon& entity, const QUrl& projectDir);
  Q_INVOKABLE EntityWeapon fromJson(const QString& id,
                                    const QJsonObject& json,
                                    const QUrl& projectDir);
};
