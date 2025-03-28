#pragma once
#include <QJSValue>
#include <QModelIndex>
#include <QQmlEngine>

template<typename T>
class BaseList
{
public:
  [[nodiscard]] int rowCount(const QModelIndex& parent = QModelIndex()) const;
  [[nodiscard]] QVariant data(const QModelIndex& index) const;
  bool setData(const QModelIndex& index, const QVariant& value);
  std::vector<T>& getData();
  const std::vector<T>& getData() const;
  [[nodiscard]] int findIndex(const QObject& qmlObject, const QJSValue& predicate) const;
  void removeIf(const QObject& qmlObject, const QJSValue& predicate);
  void push(const T& value);
  void clear();

private:
  std::vector<T> m_data {};
};

template<typename T>
int
BaseList<T>::rowCount(const QModelIndex& parent) const
{
  if (parent.isValid()) {
    return 0;
  }
  return m_data.size();
}

template<typename T>
QVariant
BaseList<T>::data(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return {};
  }
  auto idx = index.row();
  if (idx < 0 || idx >= m_data.size()) {
    return {};
  }
  return {m_data.at(idx)};
}

template<typename T>
bool
BaseList<T>::setData(const QModelIndex& index, const QVariant& value)
{
  if (data(index) == value) {
    return false;
  }
  auto idx = index.row();
  if (idx < 0 || idx >= m_data.size()) {
    qWarning() << std::format("A model index is out of bounds");
    return false;
  }
  m_data[index.row()] = value.value<T>();
  return true;
}

template<typename T>
std::vector<T>&
BaseList<T>::getData()
{
  return m_data;
}

template<typename T>
const std::vector<T>&
BaseList<T>::getData() const
{
  return m_data;
}

template<typename T>
void
BaseList<T>::push(const T& value)
{
  m_data.push_back(value);
}


template<typename T>
int
BaseList<T>::findIndex(const QObject& qmlObject, const QJSValue &predicate) const
{
  auto engine = qmlEngine(&qmlObject);
  if (!predicate.isCallable()) {
    engine->throwError(QString("Expected a callable object"));
  }
  int i = 0;
  auto length = m_data.size();
  for (; i < length; i++) {
    QJSValueList args;
    args << engine->toScriptValue(m_data[i]);
    auto result = predicate.call(args);
    if (result.toBool()) {
      return i;
    }
  }
  return -1;
}

template<typename T>
void
BaseList<T>::removeIf(const QObject& qmlObject, const QJSValue &predicate)
{
  auto engine = qmlEngine(&qmlObject);
  if (!predicate.isCallable()) {
    engine->throwError(QJSValue::TypeError, QString("Expected a callable object"));
  }
  auto handler = [&](const T& value) {
    QJSValueList args;
    args << engine->toScriptValue(value);
    auto result = predicate.call(args);
    return result.toBool();
  };
  std::erase_if(m_data, handler);
}

template<typename T>
void
BaseList<T>::clear()
{
  m_data.clear();
}
