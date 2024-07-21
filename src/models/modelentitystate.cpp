#include <QDir>
#include <QDirIterator>
#include <QQmlPropertyMap>
#include <QUrl>
#include <algorithm>
#include <iterator>

#include "src/consts.h"

#include "modelentitystate.h"

ModelEntityState::ModelEntityState(QObject* parent)
  : QAbstractListModel(parent)
{
}

int ModelEntityState::rowCount(const QModelIndex &parent) const
{
  return m_data.rowCount(parent);
}

QVariant ModelEntityState::data(const QModelIndex &index, int role) const
{
  return m_data.data(index, role);
}

bool ModelEntityState::setData(const QModelIndex &index, const QVariant &value, int role)
{
  bool result = m_data.setData(index, value, role);
  if (result) {
    emit dataChanged(index, index);
  }
  return result;
}

QModelIndex ModelEntityState::findIndexById(const QString &id)
{
  auto& data = m_data.getData();
  auto foundItem = std::ranges::find_if(data, [&id](const auto& item){
    return id == item.id();
  });
  if (foundItem != data.end()) {
    return index(std::distance(data.begin(), foundItem));
  }
  return {};
}

void
ModelEntityState::populateFromDir(const QUrl& dirPath) {
  QDirIterator files(dirPath.path(),
                     QStringList() << DEFAULT_3D_MODEL_EXT,
                     QDir::Files,
                     QDirIterator::Subdirectories);
  beginResetModel();
  auto& data = m_data.getData();
  data.clear();
  while (files.hasNext()) {
    auto filePath = files.next();
    EntityModel model;
    model.setId(filePath);
    model.setPath({filePath});
    model.setIsOpaque(true);
    m_data.push(model);
  }
  endResetModel();
}

QString
ModelEntityState::selectedModel() const
{
  return m_selectedModel;
}

void
ModelEntityState::setSelectedModel(const QString &value)
{
  if (m_selectedModel != value) {
    m_selectedModel = value;
    emit selectedModelChanged();
  }
}