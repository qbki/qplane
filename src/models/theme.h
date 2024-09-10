#pragma once

#include <QObject>
#include <QQmlEngine>

class Theme : public QObject
{
  Q_OBJECT
  QML_SINGLETON
  QML_ELEMENT

  Q_PROPERTY(double sceneOpacity READ sceneOpacity CONSTANT FINAL)

public:
  static const int SPACING = 8;

  explicit Theme(QObject* parent = nullptr);

  Q_INVOKABLE int spacing(float value);
  double sceneOpacity() const;

private:
  double m_sceneOpacity = 0.3f;
};
