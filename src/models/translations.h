#pragma once

#include <QObject>
#include <QQmlEngine>

class Translations : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QVariant file READ file WRITE setFile NOTIFY fileChanged FINAL)
  Q_PROPERTY(QVariantMap mapping READ mapping NOTIFY mappingChanged FINAL)

  QVariant m_file {};
  std::unordered_map<QString, QString> m_translations {};

public:
  explicit Translations(QObject* parent = nullptr);

  [[nodiscard]] QVariant file() const;
  void setFile(const QVariant &value);

  QVariantMap mapping() const;
  Q_INVOKABLE QString t(QString key) const;

signals:
  void fileChanged();
  void mappingChanged();

private:
  bool updateMapping(const QUrl& path);
  void clearMapping();
};
