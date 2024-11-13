#include <QDirIterator>
#include <ranges>

#include "recursivedirectorylistmodel.h"

RecursiveDirectoryListModel::RecursiveDirectoryListModel(QObject* parent)
  : QAbstractListModel(parent)
{
}

int
RecursiveDirectoryListModel::rowCount(const QModelIndex& parent) const
{
  return m_data.rowCount(parent);
}

QVariant
RecursiveDirectoryListModel::data(const QModelIndex& index, int role) const
{
  auto value = m_data.data(index, role);
  if (role == Roles::Text && value.isValid()) {
    QDir dir {m_rootFolder.toLocalFile()};
    return dir.relativeFilePath(value.toUrl().toLocalFile());
  }
  return value;
}

QUrl
RecursiveDirectoryListModel::folder() const
{
  return m_folder;
}

void
RecursiveDirectoryListModel::setFolder(const QUrl &value)
{
  if (m_folder == value) {
    return;
  }
  m_folder = value;
  emit folderChanged(m_folder);
  updateData();
}

QUrl RecursiveDirectoryListModel::rootFolder() const
{
  return m_rootFolder;
}

void RecursiveDirectoryListModel::setRootFolder(const QUrl &value)
{
  if (m_rootFolder == value) {
    return;
  }
  m_rootFolder = value;
  emit rootFolderChanged();
  emit dataChanged(index(0), index(rowCount()), {Roles::Text});
}

QVariantList
RecursiveDirectoryListModel::extentions() const
{
  QVariantList result;
  for (auto& extension : m_extentions) {
    result.push_back(extension);
  }
  return result;
}

void
RecursiveDirectoryListModel::setExtentions(const QVariantList &value)
{
  using namespace std::views;
  m_extentions.clear();
  auto extentions = std::ranges::subrange(value)
                    | transform([](const QVariant& v){ return v.toString(); })
                    | filter([](const QString& v) { return !v.isEmpty(); });
  for (const auto& extention : extentions) {
    m_extentions.push_back(extention);
  }
  emit extentionsChanged(this->extentions());
  updateData();
}

void
RecursiveDirectoryListModel::updateData()
{
  QDir dir {m_folder.toLocalFile()};
  if (!dir.exists()) {
    QQmlEngine(this).throwError(QString("Directory not exists: %1").arg(dir.absolutePath()));
    return;
  }
  if (!dir.isReadable()) {
    QQmlEngine(this).throwError(QString("Directory is not readable: %1").arg(dir.absolutePath()));
    return;
  }
  QDirIterator dirIt(m_folder.toLocalFile(), QDirIterator::Subdirectories | QDirIterator::FollowSymlinks);
  beginResetModel();
  m_data.getData().clear();
  while (dirIt.hasNext()) {
    auto fileInfo = dirIt.nextFileInfo();
    auto fileName = fileInfo.fileName();
    auto isValidExtention = std::ranges::any_of(
      m_extentions,
      [&fileName](const QString& v){ return fileName.endsWith(v); }
    );
    auto should_collect = fileInfo.isFile() && fileInfo.isReadable() && isValidExtention;
    if (should_collect) {
      m_data.push(QUrl::fromLocalFile(fileInfo.absoluteFilePath()));
    }
  }
  endResetModel();
}

QHash<int, QByteArray>
RecursiveDirectoryListModel::roleNames() const
{
  static QHash<int, QByteArray> result {
    { Roles::Value, "value", },
    { Roles::Text, "text", },
  };
  return result;
}

QModelIndex
RecursiveDirectoryListModel::findIndex(const QJSValue &predicate) const
{
  auto result = m_data.findIndex(*this, predicate);
  return result < 0
    ? QModelIndex {}
    : index(result, 0);
}
