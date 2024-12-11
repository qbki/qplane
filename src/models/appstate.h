#pragma once
#include <QObject>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class AppState : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QUrl projectDir READ projectDir WRITE setProjectDir NOTIFY projectDirChanged FINAL)
  Q_PROPERTY(QUrl levelsDir READ levelsDir NOTIFY levelsDirChanged FINAL)
  Q_PROPERTY(QUrl levelsMetaPath READ levelsMetaPath NOTIFY levelsMetaPathChanged FINAL)
  Q_PROPERTY(QUrl levelPath READ levelPath WRITE setLevelPath NOTIFY levelPathChanged FINAL)
  Q_PROPERTY(QUrl themePath READ themePath NOTIFY themePathChanged FINAL)
  Q_PROPERTY(QUrl translationPath READ translationPath NOTIFY translationPathChanged FINAL)
  Q_PROPERTY(QUrl modelsDir READ modelsDir NOTIFY modelsDirChanged FINAL)
  Q_PROPERTY(QUrl soundsDir READ soundsDir NOTIFY soundsDirChanged FINAL)
  Q_PROPERTY(bool isProjectLoaded READ isProjectLoaded NOTIFY isProjectLoadedChanged FINAL)
  Q_PROPERTY(bool isLevelLoaded READ isLevelLoaded NOTIFY isLevelLoadedChanged FINAL)
  Q_PROPERTY(bool isModelsDirExists READ isModelsDirExists NOTIFY isModelsDirExistsChanged FINAL)

  QUrl m_projectDir;
  QUrl m_levelPath;

public:
  explicit AppState(QObject* parent = nullptr);

  [[nodiscard]] QUrl projectDir() const;
  void setProjectDir(const QUrl &newProjectDir);
  [[nodiscard]] Q_INVOKABLE QString projectLocalDir() const;

  [[nodiscard]] QUrl levelPath() const;
  void setLevelPath(const QUrl &newLevelPath);

  [[nodiscard]] QUrl levelsMetaPath() const;
  [[nodiscard]] QUrl themePath() const;

  [[nodiscard]] QUrl levelsDir() const;
  [[nodiscard]] QUrl modelsDir() const;
  [[nodiscard]] QUrl soundsDir() const;

  [[nodiscard]] bool isModelsDirExists() const;
  [[nodiscard]] bool isProjectLoaded() const;
  [[nodiscard]] bool isNewLevel() const;
  [[nodiscard]] bool isLevelLoaded() const;

  [[nodiscard]] QUrl translationPath() const;

signals:
  void projectDirChanged();
  void modelsDirChanged();
  void levelsDirChanged();
  void isProjectLoadedChanged();
  void levelPathChanged();
  void isLevelLoadedChanged();
  void levelsMetaPathChanged();
  void themePathChanged();
  void soundsDirChanged();
  void isModelsDirExistsChanged();
  void translationPathChanged();
};
