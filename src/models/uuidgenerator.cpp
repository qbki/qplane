#include <QUuid>

#include "uuidgenerator.h"

UuidGenerator::UuidGenerator(QObject *parent)
  : QObject(parent)
{
}

QString
UuidGenerator::generate() const
{
  return QUuid::createUuid().toString(QUuid::StringFormat::WithoutBraces);
}

QString
UuidGenerator::generateIfEmpty(const QString &id) const
{
  return id.isEmpty() ? generate() : id;
}
