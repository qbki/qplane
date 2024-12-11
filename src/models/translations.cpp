#include <QJsonObject>
#include <QQmlEngine>

#include "src/utils/utils.h"

#include "translations.h"
#include "fileio.h"

Translations::Translations(QObject* parent)
  : QObject{ parent }
{
}

QVariant Translations::file() const
{
  return m_file;
}

void Translations::setFile(const QVariant &pathVariant)
{
  Q_ASSERT_X(pathVariant.isNull() || (pathVariant.userType() == QMetaType::QUrl),
             __func__,
             ": Must be null or url");
  if (m_file == pathVariant) {
    return;
  }
  if (pathVariant.userType() == QMetaType::QUrl) {
    updateMapping(pathVariant.toUrl());
  } else if (pathVariant.isNull()) {
    clearMapping();
  }
  m_file = pathVariant;
  emit fileChanged();
  emit mappingChanged();
}

QString
Translations::t(QString key) const
{
  if (m_translations.contains(key)) {
    return m_translations.at(key);
  }
  qInfo() << "Translation was not found: " << key;
  return key;
}

bool
Translations::updateMapping(const QUrl& path)
{
  auto& fileio = getQmlSingleton<FileIO>(this);
  auto json = fileio.loadJson(path);
  if (!json.isObject()) {
    auto message = QString("Root object must be an object: %1").arg(path.toLocalFile());
    qmlEngine(this)->throwError(message);
    return false;
  }
  auto root = json.toObject();
  for (auto& key : root.keys()) {
    auto value = root[key];
    if (!value.isString()) {
      auto message = QString("Must be a string: %1:%2").arg(path.toLocalFile(), key);
      qmlEngine(this)->throwError(message);
      return false;
    }
    m_translations[key] = value.toString();
  }
  return true;
}

void Translations::clearMapping()
{
  m_translations.clear();
}

QVariantMap
Translations::mapping() const
{
  QVariantMap result;
  for (auto& [key, value] : m_translations) {
    result[key] = value;
  }
  return result;
}
