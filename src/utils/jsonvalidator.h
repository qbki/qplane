#pragma once
#include <QColor>
#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>

class JsonValidator
{
private:
  const QObject* m_object;
  const QJsonObject* m_json;
  QString m_prefix;

public:
  JsonValidator(const QObject* object,
                const QJsonObject* json,
                QString prefix = "");

  [[nodiscard]] bool boolean(const QString& key) const;
  [[nodiscard]] double real(const QString& key) const;
  [[nodiscard]] QJsonObject obj(const QString& key) const;
  [[nodiscard]] QVariantList vectors3d(const QString& key) const;
  [[nodiscard]] QVector3D vector3d(const QString &key) const;
  [[nodiscard]] QColor color(const QString &key) const;

  [[nodiscard]] QString string(const QString& key) const;
  [[nodiscard]] QString optionalString(const QString& key, const QString& defaultValue) const;

  [[nodiscard]] QJsonArray array(const QString& key) const;
  [[nodiscard]] QJsonArray optionalArray(const QString& key, const QJsonArray& defaultValue) const;

  template<typename T>
  requires std::derived_from<T, QJSValue>
           || std::derived_from<T, QVariant>
           || std::is_floating_point_v<T>
  T
  optionalReal(const QString& key, T defaultValue) const
  {
    if (!m_json->contains(key)) {
      return defaultValue;
    }
    if (const QJsonValue value = (*m_json)[key]; value.isDouble()) {
      return value.toDouble();
    }
    throw create_error(QString("\"%1\" field must be a double type").arg(key));
  }

  template<typename T>
  requires std::is_default_constructible_v<T>
  T
  handle(const std::function<void(const JsonValidator&, T&)>& fn)
  {
    T entity;
    try {
      fn(*this, entity);
    } catch(const std::runtime_error& error) {
      auto message = m_prefix.isEmpty()
        ? error.what()
        : QString("%1: %2").arg(m_prefix, error.what());
      qmlEngine(m_object)->throwError(QJSValue::TypeError, message);
    }
    return entity;
  };

private:
  void must_contain_key(const QString& key) const;
  [[nodiscard]] std::runtime_error create_error(const QString& message) const;
};
