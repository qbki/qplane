#pragma once
#include <QColor>
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>

class JsonValidator
{
private:
  const QObject* m_object;
  const QJsonObject* m_json;

public:
  JsonValidator(const QObject* object, const QJsonObject* json);

  [[nodiscard]] bool boolean(const QString& key) const;
  [[nodiscard]] double real(const QString& key) const;
  [[nodiscard]] QVariant optionalReal(const QString &key, const QVariant& defaultValue) const;
  [[nodiscard]] QString string(const QString& key) const;
  [[nodiscard]] QJsonObject obj(const QString& key) const;
  [[nodiscard]] QString optionalString(const QString& key, const QString& defaultValue) const;
  [[nodiscard]] QVariantList vectors3d(const QString& key) const;
  [[nodiscard]] QVector3D vector3d(const QString &key) const;
  [[nodiscard]] QColor color(const QString &key) const;

private:
  void must_contain_key(const QString& key) const;
  [[nodiscard]] std::runtime_error create_error(const QString& message) const;
};
