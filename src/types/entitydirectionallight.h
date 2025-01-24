#pragma once
#include <QColor>
#include <QQmlEngine>
#include <QVector3D>

#include "entitybase.h"

class EntityDirectionalLight : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityDirectionalLight)

  Q_PROPERTY(QColor color READ color WRITE setColor FINAL)
  Q_PROPERTY(QVector3D direction READ direction WRITE setDirection FINAL)

  QColor m_color = QColor::fromRgbF(1, 1, 1);
  QVector3D m_direction = QVector3D(0, 0, -1);

public:
  EntityDirectionalLight() = default;

  [[nodiscard]] QColor color() const;
  void setColor(const QColor& value);

  [[nodiscard]] QVector3D direction() const;
  void setDirection(const QVector3D& value);

  [[nodiscard]] Q_INVOKABLE EntityDirectionalLight copy() const;
};

Q_DECLARE_METATYPE(EntityDirectionalLight)

class EntityDirectionalLightFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityDirectionalLightFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityDirectionalLight create();
  Q_INVOKABLE QJsonObject toJson(const EntityDirectionalLight& entity);
  Q_INVOKABLE EntityDirectionalLight fromJson(const QString& id, const QJsonObject& json);
};
