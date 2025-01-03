#pragma once
#include <QAbstractListModel>
#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "actionmanageritem.h"

class ActionManager : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT

  static constexpr int DEFAULT_CURSOR_POSITION = -1;

  int m_cursor = DEFAULT_CURSOR_POSITION;
  std::vector<ActionManagerItem> m_queue {};

  Q_PROPERTY(bool canUndo READ canUndo NOTIFY canUndoChanged FINAL)
  Q_PROPERTY(bool canRedo READ canRedo NOTIFY canRedoChanged FINAL)

public:
  explicit ActionManager(QObject* parent = nullptr);

  [[nodiscard]] bool canRedo() const;
  [[nodiscard]] bool canUndo() const;

  Q_INVOKABLE void push(const ActionManagerItem& value);
  [[nodiscard]] Q_INVOKABLE bool isEmpty() const;
  [[nodiscard]] Q_INVOKABLE QVariant getCurrent() const;
  Q_INVOKABLE void clear();
  Q_INVOKABLE void redo();
  Q_INVOKABLE void undo();

signals:
  void canUndoChanged();
  void canRedoChanged();

private:
  void clearTail();
};
