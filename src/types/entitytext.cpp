#include <QJsonArray>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"
#include "src/utils/jssetter.h"

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
  if (value <= 0) {
    qWarning() << __func__ << ": " << "Value should be more than zero, used 1 instead";
    m_size = 1;
    return;
  }
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

QJSValue
EntityText::width() const
{
  return m_width;
}

void
EntityText::setWidth(const QJSValue& value)
{
  m_width = JSStrictSetter(__func__, value, QJSValue::NullValue)
    .nullable()
    .number()
    .value();
}


QJSValue
EntityText::height() const
{
  return m_height;
}

void
EntityText::setHeight(const QJSValue& value)
{
  m_height = JSStrictSetter(__func__, value, QJSValue::NullValue)
    .nullable()
    .number()
    .value();
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
  if (auto value = entity.width(); value.isNumber()) {
    json["width"] = value.toNumber();
  }
  if (auto value = entity.height(); value.isNumber()) {
    json["height"] = value.toNumber();
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
      entity.setWidth(check.optionalReal("width", QJSValue {QJSValue::NullValue}));
      entity.setHeight(check.optionalReal("height", QJSValue {QJSValue::NullValue}));
    });
}
