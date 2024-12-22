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

  Q_PROPERTY(double projectileSpeed READ projectileSpeed WRITE setProjectileSpeed FINAL)
  Q_PROPERTY(double fireRate READ fireRate WRITE setFireRate FINAL)
  Q_PROPERTY(double lifetime READ lifetime WRITE setLifetime FINAL)
  Q_PROPERTY(double spread READ spread WRITE setSpread FINAL)
  Q_PROPERTY(QString projectileModelId READ projectileModelId WRITE setProjectileModelId FINAL)
  Q_PROPERTY(QUrl shotSoundPath READ shotSoundPath WRITE setShotSoundPath FINAL)

  double m_projectileSpeed {0};
  double m_fireRate {0};
  double m_lifetime {0};
  double m_spread {0};
  QString m_projectileModelId {};
  QUrl m_shotSoundPath {};

public:
  EntityWeapon() = default;

  [[nodiscard]] double projectileSpeed() const;
  void setProjectileSpeed(double value);

  [[nodiscard]] double fireRate() const;
  void setFireRate(double value);

  [[nodiscard]] double lifetime() const;
  void setLifetime(double value);

  [[nodiscard]] double spread() const;
  void setSpread(double value);

  [[nodiscard]] QString projectileModelId() const;
  void setProjectileModelId(const QString& value);

  [[nodiscard]] QUrl shotSoundPath() const;
  void setShotSoundPath(const QUrl& value);

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
