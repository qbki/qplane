#include <QDir>

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
  emit isProjectLoadedChanged();
  emit isModelsDirExistsChanged();
  emit levelsDirChanged();
  emit projectDirChanged();
  emit soundsDirChanged();
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

bool
AppState::isNewLevel() const
{
  return !m_levelPath.isEmpty();
}

QUrl
AppState::levelPath() const
{
  return m_levelPath;
}

void
AppState::setLevelPath(const QUrl &newLevelPath)
{
  if (m_levelPath == newLevelPath) {
    return;
  }
  m_levelPath = newLevelPath;
  emit levelPathChanged();
}

bool
AppState::isLevelLoaded() const
{
  return !m_levelPath.isEmpty();
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
