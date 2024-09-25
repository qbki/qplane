#pragma once
#include <QQmlEngine>
#include <QString>
#include <QUrl>

class EntityWeapon
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityWeapon)

  Q_PROPERTY(QString id READ id WRITE set_id FINAL)
  Q_PROPERTY(double projectile_speed READ projectile_speed WRITE set_projectile_speed FINAL)
  Q_PROPERTY(double fire_rate READ fire_rate WRITE set_fire_rate FINAL)
  Q_PROPERTY(double lifetime READ lifetime WRITE set_lifetime FINAL)
  Q_PROPERTY(double spread READ spread WRITE set_spread FINAL)
  Q_PROPERTY(QString projectile_model_id READ projectile_model_id WRITE set_projectile_model_id FINAL)
  Q_PROPERTY(QUrl shot_sound_path READ shot_sound_path WRITE set_shot_sound_path FINAL)

  QString m_id = "";
  double m_projectile_speed = 0;
  double m_fire_rate = 0;
  double m_lifetime = 0;
  double m_spread = 0;
  QString m_projectile_model_id = "";
  QUrl m_shot_sound_path = QString("");

public:
  EntityWeapon();

  QString id() const;
  void set_id(const QString &new_id);

  double projectile_speed() const;
  void set_projectile_speed(double value);

  double fire_rate() const;
  void set_fire_rate(double value);

  double lifetime() const;
  void set_lifetime(double value);

  double spread() const;
  void set_spread(double value);

  QString projectile_model_id() const;
  void set_projectile_model_id(const QString &value);

  QUrl shot_sound_path() const;
  void set_shot_sound_path(const QUrl &value);
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
