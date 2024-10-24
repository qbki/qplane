#pragma once
#include <QColor>
#include <QQmlEngine>
#include <QVector3D>

class EntityDirectionalLight
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityDirectionalLight)

  Q_PROPERTY(QString id READ id WRITE set_id FINAL)
  Q_PROPERTY(QColor color READ color WRITE set_color FINAL)
  Q_PROPERTY(QVector3D direction READ direction WRITE set_direction FINAL)

  QString m_id;
  QColor m_color;
  QVector3D m_direction;

public:
  EntityDirectionalLight() = default;

  QString id() const;
  void set_id(const QString &value);

  QColor color() const;
  void set_color(const QColor &value);

  QVector3D direction() const;
  void set_direction(const QVector3D &value);

  Q_INVOKABLE EntityDirectionalLight copy() const;
};

Q_DECLARE_METATYPE(EntityDirectionalLight)

class EntityDirectionalLightFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityDirectionalLightFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityDirectionalLight create();
  Q_INVOKABLE QJsonObject toJson(const EntityDirectionalLight& entity);
  Q_INVOKABLE EntityDirectionalLight fromJson(const QString& id, const QJsonObject& json);
};
