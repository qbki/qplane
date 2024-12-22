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

  Q_PROPERTY(QUrl path READ path WRITE setPath FINAL)
  Q_PROPERTY(bool isOpaque READ isOpaque WRITE setIsOpaque FINAL)

  QUrl m_path {""};
  bool m_isOpaque {true};

public:
  EntityModel() = default;

  [[nodiscard]] QUrl path() const;
  void setPath(const QUrl& new_path);

  [[nodiscard]] bool isOpaque() const;
  void setIsOpaque(bool new_isOpaque);

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
