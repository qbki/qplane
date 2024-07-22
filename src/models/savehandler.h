#pragma once
#include <QObject>
#include <QQmlEngine>

class AppState;
class ModelEntityState;

class SaveHandler : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit SaveHandler(QObject* parent = nullptr);

public slots:
  void save(AppState* appState, ModelEntityState* modelEntityState);
};
