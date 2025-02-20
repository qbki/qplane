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
  Q_PROPERTY(bool hasEmpty READ hasEmpty WRITE setHasEmpty NOTIFY hasEmptyChanged FINAL)

  enum Roles {
    Value = Qt::UserRole + 1,
    Text,
  };

  BaseList<QVariant> m_data {};
  QUrl m_folder {};
  QUrl m_rootFolder {};
  std::vector<QString> m_extentions {};
  bool m_hasEmpty {false};

public:
  explicit RecursiveDirectoryListModel(QObject* parent = nullptr);

  [[nodiscard]] int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  [[nodiscard]] QVariant data(const QModelIndex& index,
                              int role = Qt::DisplayRole) const override;

  [[nodiscard]] QUrl folder() const;
  void setFolder(const QUrl &value);

  [[nodiscard]] QUrl rootFolder() const;
  void setRootFolder(const QUrl &value);

  [[nodiscard]] QVariantList extentions() const;
  void setExtentions(const QVariantList &value);

  [[nodiscard]] QHash<int, QByteArray> roleNames() const override;
  [[nodiscard]] Q_INVOKABLE QModelIndex findIndex(const QJSValue &predicate) const;

  [[nodiscard]] bool hasEmpty() const;
  void setHasEmpty(bool newHasEmpty);

signals:
  void folderChanged(const QUrl& value);
  void extentionsChanged(const QVariantList& value);
  void rootFolderChanged();
  void hasEmptyChanged();

private:
  void updateData();
};
