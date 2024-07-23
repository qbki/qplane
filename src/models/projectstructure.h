#pragma once
#include <QObject>
#include <QQmlEngine>

class AppState;
class ModelEntityState;

class ProjectStructure : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit ProjectStructure(QObject* parent = nullptr);

public slots:
  void save(AppState* appState, ModelEntityState* modelEntityState);
  void load(AppState* appState, ModelEntityState* modelEntityState);
};
