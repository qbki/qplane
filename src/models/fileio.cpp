#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QQmlContext>

#include "fileio.h"

FileIO::FileIO(QObject* parent)
  : QObject{ parent }
{
}

bool
FileIO::isExists(const QString &filePath) const
{
  QFile file {filePath};
  return file.exists();
}

bool
FileIO::isExists(const QFile &file) const
{
  return file.exists();
}

bool
FileIO::isExists(const QUrl &file) const
{
  auto path = file.toLocalFile();
  return isExists(path);
}

QJsonValue
FileIO::loadJson(const QUrl& fileUrl) const
{
  auto localFilePath = fileUrl.toLocalFile();
  QFile file {localFilePath};

  if (!file.exists()) {
    throwJSNotFoundError(localFilePath);
    return {};
  }

  if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
    auto rawData = file.readAll();
    file.close();
    QJsonParseError jsonError;
    auto doc = QJsonDocument::fromJson(rawData, &jsonError);
    if (jsonError.error == QJsonParseError::NoError) {
      return doc.object();
    }
    throwJSParsingError(localFilePath, jsonError.errorString());
  } else {
    throwJSNotReadableError(localFilePath);
  }

  return {};
}

void
FileIO::saveJson(const QUrl& fileUrl, const QJsonValue& json) const
{
  auto localFilePath = fileUrl.toLocalFile();
  QFile file {localFilePath};
  if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
    auto doc = QJsonDocument(json.toObject());
    file.write(doc.toJson());
    file.close();
  } else {
    throwJSNotWritableError(localFilePath);
  }
}

QString FileIO::relativePath(const QUrl &dir, const QUrl &path) const
{
  return QDir{dir.toLocalFile()}.relativeFilePath(path.toLocalFile());
}

QUrl FileIO::absolutePath(const QUrl &dir, const QUrl &path) const
{
  return dir.resolved(path);
}

QString FileIO::fileName(const QUrl &path) const
{
  return path.fileName();
}

QUrl FileIO::toUrl(const QString &path) const
{
  return {path};
}

QString FileIO::toLocalFile(const QUrl &path) const
{
  return path.toLocalFile();
}

QUrl FileIO::fromLocalFile(const QString &path) const
{
  return QUrl::fromLocalFile(path);
}

void
FileIO::throwJSError(const QString &message) const
{
  qmlEngine(this)->throwError(message);
}


void
FileIO::throwJSParsingError(const QString &filePath, const QString& message) const
{
  throwJSError(QString("Parsing error %1: %2").arg(filePath, message));
}

void
FileIO::throwJSNotFoundError(const QString &filePath) const
{
  throwJSError(QString("File is not found: %1").arg(filePath));
}

void
FileIO::throwJSNotReadableError(const QString &filePath) const
{
  throwJSError(QString("File is not readable: %1").arg(filePath));
}

void
FileIO::throwJSNotWritableError(const QString &filePath) const
{
  throwJSError(QString("File is not writeable: %1").arg(filePath));
}
