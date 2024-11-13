#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QVector3D>
#include <QUrl>

#include "entityboundaries.h"
#include "entitycamera.h"

class LevelMeta
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(levelMeta)

  Q_PROPERTY(EntityCamera camera READ camera WRITE set_camera FINAL)
  Q_PROPERTY(EntityBoundaries boundaries READ boundaries WRITE set_boundaries FINAL)

  EntityCamera m_camera {};
  EntityBoundaries m_boundaries {};

public:
  LevelMeta() = default;

  [[nodiscard]] EntityCamera camera() const;
  void set_camera(const EntityCamera &value);

  [[nodiscard]] EntityBoundaries boundaries() const;
  void set_boundaries(const EntityBoundaries &value);
};

Q_DECLARE_METATYPE(LevelMeta)

class LevelMetaFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  LevelMetaFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE LevelMeta create();
  Q_INVOKABLE QJsonObject toJson(const LevelMeta& entity);
  Q_INVOKABLE LevelMeta fromJson(const QJsonObject& json);
};
