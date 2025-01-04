#pragma once
#include <QJsonObject>
#include <QList>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QUrl>
#include <QVector3D>

#include "entityboundaries.h"
#include "entitycamera.h"
#include "levellayer.h"

class LevelMeta
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(levelMeta)

  Q_PROPERTY(EntityCamera camera READ camera WRITE setCamera FINAL)
  Q_PROPERTY(EntityBoundaries boundaries READ boundaries WRITE setBoundaries FINAL)
  Q_PROPERTY(QList<LevelLayer> layers READ layers WRITE setLayers FINAL)

  EntityCamera m_camera {};
  EntityBoundaries m_boundaries {};
  QList<LevelLayer> m_layers;

public:
  LevelMeta() = default;

  [[nodiscard]] EntityCamera camera() const;
  void setCamera(const EntityCamera& value);

  [[nodiscard]] EntityBoundaries boundaries() const;
  void setBoundaries(const EntityBoundaries& value);

  [[nodiscard]] QList<LevelLayer> layers() const;
  void setLayers(const QList<LevelLayer>& newLayers);
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
