#include <QVector3D>

#include "jsonvalidator.h"

JsonValidator::JsonValidator(const QObject* object,
                             const QJsonObject* json,
                             QString prefix)
  : m_object(object)
  , m_json(json)
  , m_prefix(std::move(prefix))
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

QJsonObject
JsonValidator::obj(const QString& key) const
{
  must_contain_key(key);
  if (const QJsonValue value = (*m_json)[key]; value.isObject()) {
    return value.toObject();
  }
  throw create_error(QString("\"%1\" field must be an object type").arg(key));
}

QJsonArray
JsonValidator::array(const QString& key) const
{
  must_contain_key(key);
  return optionalArray(key, {});
}

QJsonArray
JsonValidator::optionalArray(const QString& key, const QJsonArray& defaultValue) const
{
  if (!m_json->contains(key)) {
    return defaultValue;
  }
  if (const QJsonValue value = (*m_json)[key]; value.isArray()) {
    return value.toArray();
  }
  throw create_error(QString("\"%1\" field must be an array").arg(key));
}

QString
JsonValidator::string(const QString& key) const
{
  must_contain_key(key);
  return optionalString(key, "");
}

QString
JsonValidator::optionalString(const QString& key, const QString& defaultValue) const
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
JsonValidator::vectors3d(const QString& key) const
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
      result.push_back(QVector3D(
        static_cast<float>(x.toDouble()),
        static_cast<float>(y.toDouble()),
        static_cast<float>(z.toDouble())
      ));
    }
    return result;
  }
  throw create_error(QString("\"%1\" field must be an array type").arg(key));
}

QVector3D
JsonValidator::vector3d(const QString& key) const
{
  must_contain_key(key);
  if (const QJsonValue value = (*m_json)[key]; value.isArray()) {
    const auto array = value.toArray();
    auto size = array.size();
    if (size != 3) {
      throw create_error(QString("\"%1\" field has insufficient size, expected 3 doubles").arg(key));
    }
    const auto x {array[0]};
    const auto y {array[1]};
    const auto z {array[2]};
    if (!(x.isDouble() && y.isDouble() && z.isDouble())) {
      throw create_error(QString("\"%1\" items must be a double type").arg(key));
    }
    return {
      static_cast<float>(x.toDouble()),
      static_cast<float>(y.toDouble()),
      static_cast<float>(z.toDouble())
    };
  }
  throw create_error(QString("\"%1\" field must be an array of 3 doubles").arg(key));
}

QColor
JsonValidator::color(const QString& key) const
{
  auto vector = vector3d(key);
  return QColor::fromRgbF(
    std::clamp(vector.x(), 0.0f, 1.0f),
    std::clamp(vector.y(), 0.0f, 1.0f),
    std::clamp(vector.z(), 0.0f, 1.0f)
  );
}

double
JsonValidator::real(const QString& key) const
{
  must_contain_key(key);
  return optionalReal<QVariant>(key, 0).toDouble();
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
