#pragma once
#include <QColor>
#include <QObject>
#include <QVariant>
#include <qqmlregistration.h>

#include "entitybase.h"

class EntityText : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityText)

  Q_PROPERTY(QString textId READ textId WRITE setTextId FINAL)
  Q_PROPERTY(int size READ size WRITE setSize FINAL)
  Q_PROPERTY(QColor color READ color WRITE setColor FINAL)
  Q_PROPERTY(QVariant width READ width WRITE setWidth FINAL)
  Q_PROPERTY(QVariant height READ height WRITE setHeight FINAL)

  QString m_textId {""};
  int m_size {1};
  QColor m_color {QColor::fromRgbF(0, 0, 0)};
  QVariant m_width {};
  QVariant m_height {};

public:
  EntityText() = default;

  [[nodiscard]] QString textId() const;
  void setTextId(const QString& value);

  [[nodiscard]] int size() const;
  void setSize(int value);

  [[nodiscard]] QColor color() const;
  void setColor(const QColor& value);

  [[nodiscard]] QVariant width() const;
  void setWidth(const QVariant& value);

  [[nodiscard]] QVariant height() const;
  void setHeight(const QVariant& value);

  [[nodiscard]] Q_INVOKABLE EntityText copy() const;
};

Q_DECLARE_METATYPE(EntityText)

class EntityTextFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityTextFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityText create();
  Q_INVOKABLE QJsonObject toJson(const EntityText& entity);
  Q_INVOKABLE EntityText fromJson(const QString& id, const QJsonObject& json);
};
