#pragma once
#include <QJsonValue>
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
  QJsonValue entitiesToJson(AppState* appState, ModelEntityState* modelEntityState);
  void populateEntities(const QJsonValue& json, AppState* appState, ModelEntityState* modelEntityState);

  QJsonValue levelToJson(AppState* appState, const QVariant& placedEntities);
  QVariant parseLevel(const QJsonValue& json);
};
