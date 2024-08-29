#include <QJsonArray>
#include <QVector3D>

#include "jsonvalidator.h"

JsonValidator::JsonValidator(const QObject* object, const QJsonObject* json)
  : m_object(object)
  , m_json(json)
{};

bool
JsonValidator::boolean(const QString& key) const
{
  must_contain_key(key);
  if (const QJsonValue value = (*m_json)[key]; value.isBool()) {
    return value.toBool();
  }
  throw create_error(QString("\"%1\" field must be a boolean type").arg(key));
}

QString
JsonValidator::string(const QString& key) const
{
  must_contain_key(key);
  return optionalString(key, "");
}

QString JsonValidator::optionalString(const QString &key, const QString &defaultValue) const
{
  if (!m_json->contains(key)) {
    return defaultValue;
  }
  if (const QJsonValue value = (*m_json)[key]; value.isString()) {
    return value.toString();
  }
  throw create_error(QString("\"%1\" field must be a string type").arg(key));
}

QVariantList
JsonValidator::vectors3d(const QString &key) const
{
  must_contain_key(key);
  if (const QJsonValue value = (*m_json)[key]; value.isArray()) {
    const auto array = value.toArray();
    QVariantList result;
    auto size = array.size();
    if ((size % 3) != 0) {
      throw create_error(QString("\"%1\" field has insufficient size").arg(key));
    }
    for (int i = 0; i < size; i += 3) {
      const auto x = array[i + 0];
      const auto y = array[i + 1];
      const auto z = array[i + 2];
      if (!(x.isDouble() && y.isDouble() && z.isDouble())) {
        throw create_error(QString("\"%1\" items must be a double type").arg(key));
      }
      result.push_back(QVector3D(x.toDouble(), y.toDouble(), z.toDouble()));
    }
    return result;
  }
  throw create_error(QString("\"%1\" field must be an array type").arg(key));
}

double
JsonValidator::real(const QString& key) const
{
  must_contain_key(key);
  if (const QJsonValue value = (*m_json)[key]; value.isDouble()) {
    return value.toDouble();
  }
  throw create_error(QString("\"%1\" field must be a double type").arg(key));
}

void
JsonValidator::must_contain_key(const QString& key) const
{
  if (!m_json->contains(key)) {
    throw create_error(QString("Not found \"%1\" field").arg(key));
  }
}

std::runtime_error
JsonValidator::create_error(const QString &message) const
{
  return std::runtime_error(message.toStdString());
}
