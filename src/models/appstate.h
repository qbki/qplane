#pragma once
#include <QObject>
#include <QQmlEngine>

class AppState : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QUrl projectDir READ projectDir WRITE setProjectDir NOTIFY projectDirChanged FINAL)
  Q_PROPERTY(QUrl levelsDir READ levelsDir NOTIFY levelsDirChanged FINAL)
  Q_PROPERTY(QUrl levelsMetaPath READ levelsMetaPath NOTIFY levelsMetaPathChanged FINAL)
  Q_PROPERTY(QUrl levelPath READ levelPath WRITE setLevelPath NOTIFY levelPathChanged FINAL)
  Q_PROPERTY(QUrl modelsDir READ modelsDir NOTIFY modelsDirChanged FINAL)
  Q_PROPERTY(bool isProjectLoaded READ isProjectLoaded NOTIFY isProjectLoadedChanged FINAL)
  Q_PROPERTY(bool isLevelLoaded READ isLevelLoaded NOTIFY isLevelLoadedChanged FINAL)
  Q_PROPERTY(bool isModelsDirExists READ isModelsDirExists FINAL)

public:
  explicit AppState(QObject* parent = nullptr);

  QUrl projectDir() const;
  void setProjectDir(const QUrl &newProjectDir);
  Q_INVOKABLE QString projectLocalDir() const;

  QUrl levelPath() const;
  void setLevelPath(const QUrl &newLevelPath);

  QUrl modelsDir() const;
  QUrl levelsDir() const;

  bool isModelsDirExists() const;
  bool isProjectLoaded() const;
  bool isNewLevel() const;
  bool isLevelLoaded() const;

  QUrl levelsMetaPath() const;

signals:
  void projectDirChanged();
  void modelsDirChanged();
  void levelsDirChanged();
  void isProjectLoadedChanged();
  void levelPathChanged();
  void isLevelLoadedChanged();
  void levelsMetaPathChanged();

private:
  QUrl m_projectDir;
  QUrl m_levelPath;
};
