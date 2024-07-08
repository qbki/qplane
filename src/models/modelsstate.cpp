#include <QUrl>
#include <algorithm>

#include "src/consts.h"

#include "modelsstate.h"

ModelsState::ModelsState(QObject* parent)
  : QAbstractListModel(parent)
  , _header(tr("Models"))
{
}

QVariant
ModelsState::headerData(int section,
                        Qt::Orientation orientation,
                        int role) const
{
  return _header;
}

bool
ModelsState::setHeaderData(int section,
                           Qt::Orientation orientation,
                           const QVariant& value,
                           int role)
{
  if (value != headerData(section, orientation, role)) {
    _header = value;
    emit headerDataChanged(orientation, section, section);
    return true;
  }
  return false;
}

int
ModelsState::rowCount(const QModelIndex& parent) const
{
  if (parent.isValid()) {
    return 0;
  }
  return _data.size();
}

QVariant
ModelsState::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }

  auto idx = index.row();
  if (idx < 0 || idx >= _data.size()) {
    return QVariant();
  }

  if (role == Qt::DisplayRole) {
    return _data.at(idx);
  }

  return QVariant();
}

bool
ModelsState::setData(const QModelIndex& index, const QVariant& value, int role)
{
  auto idx = index.row();
  if (idx < 0 || idx >= _data.size()) {
    return false;
  }
  if (data(index, role) != value) {
    _data[index.row()] = value;
    emit dataChanged(index, index, { role });
    return true;
  }
  return false;
}

Qt::ItemFlags
ModelsState::flags(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return Qt::NoItemFlags;
  }
  return QAbstractItemModel::flags(index) | Qt::ItemIsEditable;
}

void
ModelsState::populateFromDir(const QUrl& dirPath) {
  QDirIterator files(dirPath.path(),
                     QStringList() << DEFAULT_3D_MODEL_EXT,
                     QDir::Files,
                     QDirIterator::Subdirectories);
  beginResetModel();
  _data.clear();
  while (files.hasNext()) {
    _data << files.next();
  }
  endResetModel();
}
