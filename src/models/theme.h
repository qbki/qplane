#pragma once
#include <QColor>
#include <QObject>
#include <QQmlEngine>

class Theme : public QObject
{
public:
  static constexpr int SPACING = 8;
  static constexpr float DEFAULT_SCENE_OPACITY = 0.3f;
  static const QColor ERROR_COLOR;

private:
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT
  Q_PROPERTY(double sceneOpacity READ sceneOpacity CONSTANT FINAL)
  Q_PROPERTY(QColor errorColor READ errorColor CONSTANT FINAL)

  double m_sceneOpacity = DEFAULT_SCENE_OPACITY;

public:
  explicit Theme(QObject* parent = nullptr);

  Q_INVOKABLE int spacing(float value);
  [[nodiscard]] double sceneOpacity() const;
  [[nodiscard]] QColor errorColor() const;
};
