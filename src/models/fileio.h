#pragma once
#include <QFile>
#include <QJsonValue>
#include <QObject>
#include <QQmlEngine>

class FileIO : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit FileIO(QObject* parent = nullptr);

  [[nodiscard]] Q_INVOKABLE bool isExists(const QString& filePath) const;
  [[nodiscard]] Q_INVOKABLE bool isExists(const QFile& file) const;
  [[nodiscard]] Q_INVOKABLE bool isExists(const QUrl& file) const;
  [[nodiscard]] Q_INVOKABLE QJsonValue loadJson(const QUrl& fileUrl) const;
  Q_INVOKABLE void saveJson(const QUrl& fileUrl, const QJsonValue& json) const;
  [[nodiscard]] Q_INVOKABLE QString relativePath(const QUrl& dir, const QUrl& path) const;
  [[nodiscard]] Q_INVOKABLE QUrl absolutePath(const QUrl& dir, const QUrl& path) const;
  [[nodiscard]] Q_INVOKABLE QString fileName(const QUrl& path) const;
  [[nodiscard]] Q_INVOKABLE QUrl toUrl(const QString& path) const;
  [[nodiscard]] Q_INVOKABLE QString toLocalFile(const QUrl& path) const;
  [[nodiscard]] Q_INVOKABLE QUrl fromLocalFile(const QString& path) const;

private:
  void throwJSParsingError(const QString &filePath, const QString& message) const;
  void throwJSError(const QString& message) const;
  void throwJSNotFoundError(const QString& filePath) const;
  void throwJSNotReadableError(const QString& filePath) const;
  void throwJSNotWritableError(const QString& filePath) const;
};
