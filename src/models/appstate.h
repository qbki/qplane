#pragma once
#include <QObject>
#include <QQmlEngine>

class AppState : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QUrl projectDir READ projectDir WRITE setProjectDir NOTIFY projectDirChanged FINAL)
  Q_PROPERTY(QUrl levelsDir READ levelsDir NOTIFY levelsDirChanged FINAL)
  Q_PROPERTY(QUrl modelsDir READ modelsDir NOTIFY modelsDirChanged FINAL)
  Q_PROPERTY(bool isProjectLoaded READ isProjectLoaded NOTIFY isProjectLoadedChanged FINAL)
  Q_PROPERTY(bool isModelsDirExists READ isModelsDirExists FINAL)

public:
  explicit AppState(QObject* parent = nullptr);

  QUrl projectDir() const;
  void setProjectDir(const QUrl &newProjectDir);

  QUrl modelsDir() const;
  bool isModelsDirExists() const;
  QUrl levelsDir() const;
  bool isProjectLoaded() const;

signals:
  void projectDirChanged();
  void modelsDirChanged();
  void levelsDirChanged();
  void isProjectLoadedChanged();

private:
  QUrl m_projectDir;
  QUrl m_levelsDir;
};
