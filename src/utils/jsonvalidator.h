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

  bool boolean(const QString& key) const;
  double real(const QString& key) const;
  QString string(const QString& key) const;
  QString optionalString(const QString& key, const QString& defaultValue) const;
  QVariantList vectors3d(const QString& key) const;
  QVector3D vector3d(const QString &key) const;
  QColor color(const QString &key) const;

private:
  void must_contain_key(const QString& key) const;
  std::runtime_error create_error(const QString& message) const;
};
