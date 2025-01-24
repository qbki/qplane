#pragma once
#include <QColor>
#include <QObject>
#include <QQmlEngine>

class QmlConsts : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
  Q_PROPERTY(QString DEFAULT_SCENE_LAYER_ID READ defaultSceneLayerId CONSTANT FINAL)
  Q_PROPERTY(QColor INVALID_COLOR READ invalidColor CONSTANT FINAL)

public:
  explicit QmlConsts(QObject* parent = nullptr);
  [[nodiscard]] QString defaultSceneLayerId() const;
  [[nodiscard]] QColor invalidColor() const;
};
