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

QString
GadgetListModel::selectedModel() const
{
  return m_selectedModel;
}

void
GadgetListModel::setSelectedModel(const QString &value)
{
  if (m_selectedModel != value) {
    m_selectedModel = value;
    emit selectedModelChanged();
  }
}

QModelIndex GadgetListModel::findIndex(const QJSValue &predicate) const
{
  auto engine = qmlEngine(this);
  if (!predicate.isCallable()) {
    engine->throwError(QString("Expected a callable object"));
  }
  int i = 0;
  auto data = m_data.getData();
  for (; i < m_data.rowCount(); i++) {
    QJSValueList args;
    args << engine->toScriptValue(data[i]);
    auto result = predicate.call(args);
    if (result.toBool()) {
      return index(i, 0);
    }
  }
  return {};
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
