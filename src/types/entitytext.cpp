#include <QJsonArray>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entitytext.h"

QString
EntityText::text_id() const
{
  return m_text_id;
}

void
EntityText::set_text_id(QString value)
{
  m_text_id = value;
}

int
EntityText::size() const
{
  return m_size;
}

void
EntityText::set_size(int value)
{
  Q_ASSERT_X(value > 0, __func__, "Value should be more than zero");
  m_size = value;
}


QColor
EntityText::color() const
{
  return m_color;
}

void
EntityText::set_color(const QColor &value)
{
  m_color = value;
}

QVariant
EntityText::width() const
{
  return m_width;
}

void
EntityText::set_width(const QVariant &value)
{
  m_width = value;
}


QVariant
EntityText::height() const
{
  return m_height;
}

void
EntityText::set_height(const QVariant &value)
{
  m_height = value;
}

EntityText
EntityText::copy() const
{
  return *this;
}

EntityTextFactory::EntityTextFactory(QObject *parent)
  : QObject(parent)
{
}

EntityText
EntityTextFactory::create()
{
  return {};
}

QJsonObject
EntityTextFactory::toJson(const EntityText &entity)
{
  auto color = entity.color();
  QJsonObject json;
  json["id"] = entity.id();
  json["name"] = entity.name();
  json["kind"] = "text";
  json["size"] = entity.size();
  json["text_id"] = entity.text_id();
  json["color"] = QJsonArray {color.redF(), color.greenF(), color.blueF()};
  if (auto value = entity.width(); !value.isNull()) {
    json["width"] = value.toDouble();
  }
  if (auto value = entity.height(); !value.isNull()) {
    json["height"] = value.toDouble();
  }
  return json;
}

EntityText
EntityTextFactory::fromJson(const QString &id, const QJsonObject &json)
{
  return JsonValidator(this, &json, id)
    .handle<EntityText>([&](const JsonValidator& check, EntityText& entity) {
      entity.set_id(id);
      entity.set_name(check.string("name"));
      entity.set_color(check.color("color"));
      entity.set_size(static_cast<int>(check.real("size")));
      entity.set_text_id(check.string("text_id"));
      entity.set_width(check.optionalReal("width", {}));
      entity.set_height(check.optionalReal("height", {}));
    });
}
