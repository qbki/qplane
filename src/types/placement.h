#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QQuick3DInstancing>
#include <QVector3D>

class Placement
{
  Q_GADGET
  Q_PROPERTY(QString id READ id WRITE setId FINAL)
  Q_PROPERTY(QString behaviour READ behaviour WRITE setBehaviour FINAL)
  QML_NAMED_ELEMENT(placement)

public:
  Placement();

  QString id() const;
  void setId(const QString &newId);

  QString behaviour() const;
  void setBehaviour(const QString &newBehaviour);

  const std::vector<QVector3D>& getPositions() const;
  Q_INVOKABLE QVariant getQmlPositions() const;
  Q_INVOKABLE void pushPosition(const QVector3D& position);

private:
  QString m_id;
  QString m_behaviour;
  std::vector<QVector3D> m_positions;
};

Q_DECLARE_METATYPE(Placement)

class PlacementFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  PlacementFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE Placement create();
};
