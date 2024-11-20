#include "entitybase.h"

QString EntityBase::id() const
{
  return m_id;
}

void EntityBase::set_id(const QString &value)
{
  m_id = value;
}

QString EntityBase::name() const
{
  return m_name;
}

void EntityBase::set_name(const QString &value)
{
  m_name = value;
}
