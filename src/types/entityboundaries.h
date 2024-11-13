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
  Q_PROPERTY(QVector3D min READ min WRITE set_min FINAL)
  Q_PROPERTY(QVector3D max READ max WRITE set_max FINAL)

  QVector3D m_min {0, 0, 0};
  QVector3D m_max {0, 0, 0};

public:
  EntityBoundaries() = default;

  [[nodiscard]] QVector3D min() const;
  void set_min(const QVector3D &newMin);

  [[nodiscard]] QVector3D max() const;
  void set_max(const QVector3D &newMax);
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
