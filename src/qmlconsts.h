#pragma once
#include <QObject>
#include <QQmlEngine>

class QmlConsts : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QString DEFAULT_SCENE_LAYER_ID READ defaultSceneLayerId CONSTANT FINAL)

public:
  explicit QmlConsts(QObject* parent = nullptr);
  [[nodiscard]] QString defaultSceneLayerId() const;
};
