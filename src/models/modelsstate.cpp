#include <QUrl>

#include "src/consts.h"

#include "modelsstate.h"

ModelsState::ModelsState(QObject* parent)
  : QAbstractListModel(parent)
  , m_header(tr("Models"))
{
}

QVariant
ModelsState::headerData(int section,
                        Qt::Orientation orientation,
                        int role) const
{
  return m_header;
}

bool
ModelsState::setHeaderData(int section,
                           Qt::Orientation orientation,
                           const QVariant& value,
                           int role)
{
  if (value != headerData(section, orientation, role)) {
    m_header = value;
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
  return m_data.size();
}

QVariant
ModelsState::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }

  auto idx = index.row();
  if (idx < 0 || idx >= m_data.size()) {
    return QVariant();
  }

  if (role == Qt::DisplayRole) {
    return m_data.at(idx);
  }

  return QVariant();
}

bool
ModelsState::setData(const QModelIndex& index, const QVariant& value, int role)
{
  auto idx = index.row();
  if (idx < 0 || idx >= m_data.size()) {
    return false;
  }
  if (data(index, role) != value) {
    m_data[index.row()] = value;
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
  m_data.clear();
  while (files.hasNext()) {
    m_data << files.next();
  }
  endResetModel();
}

QString
ModelsState::selectedModel() const
{
  return m_selectedModel;
}

void
ModelsState::setSelectedModel(const QString& value)
{
  if (m_selectedModel != value) {
    m_selectedModel = value;
    emit selectedModelChanged();
  }
}
