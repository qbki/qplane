#pragma once
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QUrl>
#include <QVariantList>

#include "baselist.h"

class RecursiveDirectoryListModel : public QAbstractListModel
{
private:
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QUrl folder READ folder WRITE setFolder NOTIFY folderChanged FINAL)
  Q_PROPERTY(QUrl rootFolder READ rootFolder WRITE setRootFolder NOTIFY rootFolderChanged FINAL)
  Q_PROPERTY(QVariantList extentions READ extentions WRITE setExtentions NOTIFY extentionsChanged FINAL)

  BaseList<QVariant> m_data {};
  QUrl m_folder {};
  QUrl m_rootFolder {};
  std::vector<QString> m_extentions {};

  enum Roles {
    Value = Qt::UserRole + 1,
    Text,
  };

public:
  explicit RecursiveDirectoryListModel(QObject* parent = nullptr);

  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  QVariant data(const QModelIndex& index,
                int role = Qt::DisplayRole) const override;

  QUrl folder() const;
  void setFolder(const QUrl &value);

  QUrl rootFolder() const;
  void setRootFolder(const QUrl &value);

  QVariantList extentions() const;
  void setExtentions(const QVariantList &value);

  QHash<int, QByteArray> roleNames() const override;
  Q_INVOKABLE QModelIndex findIndex(const QJSValue &predicate) const;

signals:
  void folderChanged(const QUrl& value);
  void extentionsChanged(const QVariantList& value);
  void rootFolderChanged();

private:
  void updateData();
};
