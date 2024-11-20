#pragma once
#include <QObject>
#include <QQmlEngine>

class Clipboard : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT

public:
  explicit Clipboard(QObject* parent = nullptr);

  Q_INVOKABLE void copy(const QString& text) const;
};
