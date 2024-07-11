#include <QDir>

#include "src/consts.h"

#include "appstate.h"

AppState::AppState(QObject* parent)
  : QObject{ parent }
{
}

QUrl AppState::projectDir() const
{
  return m_projectDir;
}

void AppState::setProjectDir(const QUrl &newProjectDir)
{
  if (m_projectDir.matches(newProjectDir, QUrl::NormalizePathSegments)) {
    return;
  }
  m_projectDir = newProjectDir;
  emit projectDirChanged();
}

QUrl AppState::modelsDir() const
{
  auto projectDir = QDir{m_projectDir.toString(QUrl::NormalizePathSegments)};
  return projectDir.filePath(PROJECT_MODELS_DIR);
}

bool AppState::isModelsDirExists() const
{
  QDir models_dir {modelsDir().path()};
  return models_dir.exists();
}
