#include "entitybase.h"

QString EntityBase::id() const
{
  return m_id;
}

void EntityBase::setId(const QString& value)
{
  m_id = value;
}

QString EntityBase::name() const
{
  return m_name;
}

void EntityBase::setName(const QString& value)
{
  m_name = value;
}
