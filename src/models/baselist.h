#pragma once
#include <QAbstractListModel>

template<typename T>
class BaseList
{
public:
  int rowCount(const QModelIndex& parent = QModelIndex()) const;

  QVariant data(const QModelIndex& index,
                int role = Qt::DisplayRole) const;

  bool setData(const QModelIndex& index,
               const QVariant& value,
               int role = Qt::EditRole);

  std::vector<T>& getData();
  const std::vector<T>& getData() const;

public slots:
  void push(const T& value);

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
BaseList<T>::data(const QModelIndex& index, int /*role*/) const
{
  if (!index.isValid()) {
    return QVariant();
  }
  auto idx = index.row();
  if (idx < 0 || idx >= m_data.size()) {
    return QVariant();
  }
  QVariant result;
  result.setValue(m_data.at(idx));
  return result;
}

template<typename T>
bool
BaseList<T>::setData(const QModelIndex& index, const QVariant& value, int role)
{
  if (data(index, role) == value) {
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
