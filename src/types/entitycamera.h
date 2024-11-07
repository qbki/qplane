#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QVector3D>
#include <QUrl>

class EntityCamera
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityCamera)
  Q_PROPERTY(QVector3D position READ position WRITE set_position FINAL)

  QVector3D m_position;

public:
  EntityCamera() = default;
  QVector3D position() const;
  void set_position(const QVector3D &newPosition);
};

Q_DECLARE_METATYPE(EntityCamera)

class EntityCameraFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityCameraFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityCamera create();
  Q_INVOKABLE QJsonObject toJson(const EntityCamera& entity);
  Q_INVOKABLE EntityCamera fromJson(const QJsonObject& json);
};
