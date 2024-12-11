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

  Q_PROPERTY(QString text_id READ text_id WRITE set_text_id FINAL)
  Q_PROPERTY(int size READ size WRITE set_size FINAL)
  Q_PROPERTY(QColor color READ color WRITE set_color FINAL)
  Q_PROPERTY(QVariant width READ width WRITE set_width FINAL)
  Q_PROPERTY(QVariant height READ height WRITE set_height FINAL)

  QString m_text_id {""};
  int m_size {1};
  QColor m_color {QColor::fromRgbF(0, 0, 0)};
  QVariant m_width {};
  QVariant m_height {};

public:
  EntityText() = default;

  [[nodiscard]] QString text_id() const;
  void set_text_id(QString value);

  [[nodiscard]] int size() const;
  void set_size(int newSize);

  [[nodiscard]] QColor color() const;
  void set_color(const QColor &value);

  [[nodiscard]] QVariant width() const;
  void set_width(const QVariant &value);

  [[nodiscard]] QVariant height() const;
  void set_height(const QVariant &value);

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
