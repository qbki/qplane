#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QUrl>

#include "entitybase.h"

class EntityModel : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityModel)

  Q_PROPERTY(QUrl path READ path WRITE set_path FINAL)
  Q_PROPERTY(bool is_opaque READ is_opaque WRITE set_is_opaque FINAL)

  QUrl m_path {""};
  bool m_is_opaque {true};

public:
  EntityModel() = default;

  [[nodiscard]] QUrl path() const;
  void set_path(const QUrl &new_path);

  [[nodiscard]] bool is_opaque() const;
  void set_is_opaque(bool new_is_opaque);

  [[nodiscard]] Q_INVOKABLE EntityModel copy() const;
};

Q_DECLARE_METATYPE(EntityModel)

class EntityModelFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityModelFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityModel create();
  Q_INVOKABLE QJsonObject toJson(const EntityModel& entity, const QUrl& projectDir);
  Q_INVOKABLE EntityModel fromJson(const QString& id,
                                   const QJsonObject& json,
                                   const QUrl& projectDir);
};
