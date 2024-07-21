#include "entitymodel.h"

EntityModel::EntityModel() {}

QString EntityModel::id() const
{
  return m_id;
}

void EntityModel::setId(const QString &newId)
{
  m_id = newId;
}

QUrl EntityModel::path() const
{
  return m_path;
}

void EntityModel::setPath(const QUrl &newPath)
{
  m_path = newPath;
}

bool EntityModel::isOpaque() const
{
  return m_isOpaque;
}

void EntityModel::setIsOpaque(bool newIsOpaque)
{
  m_isOpaque = newIsOpaque;
}

EntityModelFactory::EntityModelFactory(QObject* parent)
  : QObject(parent)
{
}

EntityModel EntityModelFactory::create()
{
  return {};
}
