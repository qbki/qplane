#include "actionmanager.h"

ActionManager::ActionManager(QObject* parent)
  : QObject(parent)
{
}

void ActionManager::push(const ActionManagerItem &value)
{
  clearTail();
  m_queue.push_back(value);
  m_cursor += 1;
  emit canUndoChanged();
  emit canRedoChanged();
}

bool ActionManager::isEmpty() const
{
  return m_queue.empty();
}

bool ActionManager::canRedo() const
{
  return (m_cursor + 1) < m_queue.size();
}

bool ActionManager::canUndo() const
{
  return m_cursor >= 0;
}

QVariant ActionManager::getCurrent() const
{
  if (m_queue.size() == 0) {
    return QJSValue::NullValue;
  }
  return QVariant::fromValue(m_queue.at(m_cursor));
}

void ActionManager::clear()
{
  m_queue.clear();
  m_cursor = DEFAULT_CURSOR_POSITION;
  emit canUndoChanged();
  emit canRedoChanged();
}

void ActionManager::redo()
{
  if (canRedo()) {
    m_cursor = m_cursor + 1;
    m_queue.at(m_cursor).execute();
    emit canUndoChanged();
    emit canRedoChanged();
  }
}

void ActionManager::undo()
{
  if (canUndo()) {
    m_queue.at(m_cursor).undo();
    m_cursor -= 1;
    emit canUndoChanged();
    emit canRedoChanged();
  }
}

void ActionManager::clearTail()
{
  auto start = m_queue.begin() + m_cursor + 1;
  auto end = m_queue.end();
  if (start < end) {
    m_queue.erase(start, end);
  }
}
