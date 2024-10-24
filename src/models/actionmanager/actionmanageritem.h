#pragma once
#include <QObject>
#include <QQmlEngine>

class ActionManagerItem
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(actionManagerItem)

  Q_PROPERTY(QJSValue executeCb READ executeCb WRITE setExecuteCb FINAL)
  Q_PROPERTY(QJSValue undoCb READ undoCb WRITE setUndoCb FINAL)

  QJSValue m_executeCb = QJSValue::NullValue;
  QJSValue m_undoCb = QJSValue::NullValue;

public:
  ActionManagerItem();

  QJSValue executeCb() const;
  void setExecuteCb(const QJSValue &value);

  QJSValue undoCb() const;
  void setUndoCb(const QJSValue &value);

  Q_INVOKABLE void execute();
  Q_INVOKABLE void undo();
};

Q_DECLARE_METATYPE(ActionManagerItem)


class ActionManagerItemFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  ActionManagerItemFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE ActionManagerItem create();
  Q_INVOKABLE ActionManagerItem create(const QJSValue& execute, const QJSValue& undo);
};
