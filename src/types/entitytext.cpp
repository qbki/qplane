#include <QJsonArray>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entitytext.h"

QString
EntityText::textId() const
{
  return m_textId;
}

void
EntityText::setTextId(const QString& value)
{
  m_textId = value;
}

int
EntityText::size() const
{
  return m_size;
}

void
EntityText::setSize(int value)
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
EntityText::setColor(const QColor& value)
{
  m_color = value;
}

QVariant
EntityText::width() const
{
  return m_width;
}

void
EntityText::setWidth(const QVariant& value)
{
  m_width = value;
}


QVariant
EntityText::height() const
{
  return m_height;
}

void
EntityText::setHeight(const QVariant& value)
{
  m_height = value;
}

EntityText
EntityText::copy() const
{
  return *this;
}

EntityTextFactory::EntityTextFactory(QObject* parent)
  : QObject(parent)
{
}

EntityText
EntityTextFactory::create()
{
  return {};
}

QJsonObject
EntityTextFactory::toJson(const EntityText& entity)
{
  auto color = entity.color();
  QJsonObject json;
  json["id"] = entity.id();
  json["name"] = entity.name();
  json["kind"] = "text";
  json["size"] = entity.size();
  json["text_id"] = entity.textId();
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
EntityTextFactory::fromJson(const QString& id, const QJsonObject& json)
{
  return JsonValidator(this, &json, id)
    .handle<EntityText>([&](const JsonValidator& check, EntityText& entity) {
      entity.setId(id);
      entity.setName(check.string("name"));
      entity.setColor(check.color("color"));
      entity.setSize(static_cast<int>(check.real("size")));
      entity.setTextId(check.string("text_id"));
      entity.setWidth(check.optionalReal("width", {}));
      entity.setHeight(check.optionalReal("height", {}));
    });
}
