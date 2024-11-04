#include <QDir>
#include <QDirIterator>
#include <QQmlPropertyMap>
#include <QUrl>
#include <algorithm>
#include <iterator>

#include "gadgetlistmodel.h"

GadgetListModel::GadgetListModel(QObject* parent)
  : QAbstractListModel(parent)
{
}

int GadgetListModel::rowCount(const QModelIndex &parent) const
{
  return m_data.rowCount(parent);
}

QVariant GadgetListModel::data(const QModelIndex &index, int role) const
{
  return m_data.data(index, role);
}

bool GadgetListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
  bool result = m_data.setData(index, value, role);
  if (result) {
    emit dataChanged(index, index);
  }
  return result;
}

std::vector<QVariant>&
GadgetListModel::internalData()
{
  return m_data.getData();
}

void GadgetListModel::append(const QVariant &value)
{
  auto idx = m_data.rowCount();
  beginInsertRows(QModelIndex{}, idx, idx);
  m_data.push(value);
  endInsertRows();
}

void GadgetListModel::appendList(const QVariantList &value)
{
  auto size = value.size();
  if (size == 0) {
    return;
  }
  auto idx = m_data.rowCount();
  beginInsertRows(QModelIndex{}, idx, idx + size - 1);
  for (auto& item : value) {
    m_data.push(item);
  }
  endInsertRows();
}

QJSValue GadgetListModel::toArray()
{
  auto engine = qmlEngine(this);
  auto data = m_data.getData();
  auto size = data.size();
  auto jsArray = engine->newArray(data.size());
  for (int i = 0; i < size; i++) {
    jsArray.setProperty(i, engine->toScriptValue(data[i]));
  }
  return jsArray;
}

QModelIndex GadgetListModel::findIndex(const QJSValue &predicate) const
{
  auto result = m_data.findIndex(*this, predicate);
  return result < 0
    ? QModelIndex {}
    : index(result, 0);
}

void GadgetListModel::remove(const QJSValue &predicate)
{
  beginResetModel();
  m_data.removeIf(*this, predicate);
  endResetModel();
}

void
GadgetListModel::updateWholeModel(const std::vector<QVariant>& new_data)
{
  beginResetModel();
  auto& data = m_data.getData();
  data.clear();
  std::ranges::copy(new_data, std::back_inserter(data));
  endResetModel();
}

bool GadgetListModel::removeRows(int row, int count, const QModelIndex &parent)
{
  beginRemoveRows(QModelIndex{}, row, row + count - 1);
  auto& data = m_data.getData();
  data.erase(data.begin() + row, data.begin() + row + count);
  endRemoveRows();
  return true;
}
