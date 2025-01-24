#include <QDir>
#include <QJSValue>
#include <QUrl>
#include <QtLogging>

#include "src/consts.h"

#include "appstate.h"

AppState::AppState(QObject* parent)
  : QObject{ parent }
{
}

QUrl
AppState::projectDir() const
{
  return m_projectDir;
}

QString
AppState::projectLocalDir() const
{
  return m_projectDir.toLocalFile();
}

void
AppState::setProjectDir(const QUrl& newProjectDir)
{
  auto directory = newProjectDir;
  // This slash helps in resolving correct pathes.
  // Without it QUrl::resolved ignores the last path
  // component of the original url.
  directory.setPath(directory.path() + "/");
  if (m_projectDir.matches(directory, QUrl::NormalizePathSegments)) {
    return;
  }
  m_projectDir = directory;
  emit isModelsDirExistsChanged();
  emit isProjectLoadedChanged();
  emit levelsDirChanged();
  emit projectDirChanged();
  emit soundsDirChanged();
  emit translationPathChanged();
}

QUrl
AppState::modelsDir() const
{
  return m_projectDir.resolved(PROJECT_MODELS_DIR);
}

bool
AppState::isModelsDirExists() const
{
  QDir dir{modelsDir().toLocalFile()};
  return dir.exists();
}

QUrl
AppState::levelsDir() const
{
  return m_projectDir.resolved(PROJECT_LEVELS_DIR + "/");
}

bool
AppState::isProjectLoaded() const
{
  return !m_projectDir.isEmpty();
}

QVariant
AppState::levelPath() const
{
  return m_levelPath;
}

void
AppState::setLevelPath(const QVariant& value)
{
  if (m_levelPath == value) {
    return;
  }
  bool isJsNull = (value.typeId() == QMetaType::QJsonValue) && value.value<QJSValue>().isNull();
  bool isUrl = value.typeId() == QMetaType::QUrl;
  bool isValidValue = isJsNull || isUrl;
  if (isValidValue) {
    m_levelPath = value;
  } else {
    qWarning() << "Type error: a level path should be null or url. Used null instead.";
    m_levelPath = QVariant::fromValue(QJSValue(QJSValue::SpecialValue::NullValue));
  }
  emit levelPathChanged();
  emit isLevelLoadedChanged();
}

bool
AppState::isLevelLoaded() const
{
  return m_levelPath.typeId() == QMetaType::QUrl;
}

QUrl
AppState::levelsMetaPath() const
{
  return levelsDir().resolved(PROJECT_LEVELS_META_FILE);
}

QUrl AppState::themePath() const
{
  return levelsDir().resolved(PROJECT_THEME_FILE);
}

QUrl AppState::soundsDir() const
{
  return projectDir().resolved(PROJECT_SOUNDS_DIR);
}

QUrl AppState::translationPath() const
{
  return projectDir().resolved(PROJECT_TRANSLATION_FILE);
}
