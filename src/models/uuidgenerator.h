#pragma once
#include <QObject>
#include <QQmlEngine>

class UuidGenerator : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT

public:
  UuidGenerator(QObject* parent = nullptr);

  [[nodiscard]] Q_INVOKABLE QString generate() const;
  [[nodiscard]] Q_INVOKABLE QString generateIfEmpty(const QString& id) const;
};
