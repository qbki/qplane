#pragma once
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QVector3D>

class EntityBoundaries
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityBoundaries)
  Q_PROPERTY(QVector3D min READ min WRITE setMin FINAL)
  Q_PROPERTY(QVector3D max READ max WRITE setMax FINAL)

  QVector3D m_min {0, 0, 0};
  QVector3D m_max {0, 0, 0};

public:
  EntityBoundaries() = default;
  EntityBoundaries(QVector3D min, QVector3D max);

  [[nodiscard]] QVector3D min() const;
  void setMin(const QVector3D& value);

  [[nodiscard]] QVector3D max() const;
  void setMax(const QVector3D& value);
};

Q_DECLARE_METATYPE(EntityBoundaries)

class EntityBoundariesFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityBoundariesFactory(QObject* parent = Q_NULLPTR);
  [[nodiscard]] Q_INVOKABLE EntityBoundaries create() const;
  [[nodiscard]] Q_INVOKABLE QJsonObject toJson(const EntityBoundaries& entity) const;
  [[nodiscard]] Q_INVOKABLE EntityBoundaries fromJson(const QJsonObject& json) const;
};
