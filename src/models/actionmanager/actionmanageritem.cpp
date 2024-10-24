#include "actionmanageritem.h"

ActionManagerItem::ActionManagerItem() {}

QJSValue ActionManagerItem::executeCb() const
{
  return m_executeCb;
}

void ActionManagerItem::setExecuteCb(const QJSValue &value)
{
  m_executeCb = value;
}

QJSValue ActionManagerItem::undoCb() const
{
  return m_undoCb;
}

void ActionManagerItem::setUndoCb(const QJSValue &value)
{
  m_undoCb = value;
}

void ActionManagerItem::execute()
{
  if (m_executeCb.isCallable()) {
    m_executeCb.call();
  }
}

void ActionManagerItem::undo()
{
  if (m_undoCb.isCallable()) {
    m_undoCb.call();
  }
}

ActionManagerItemFactory::ActionManagerItemFactory(QObject *parent)
  : QObject(parent)
{
}

ActionManagerItem ActionManagerItemFactory::create()
{
  return {};
}

ActionManagerItem ActionManagerItemFactory::create(const QJSValue &execute, const QJSValue &undo)
{
  ActionManagerItem instance;
  instance.setExecuteCb(execute);
  instance.setUndoCb(undo);
  return instance;
}
