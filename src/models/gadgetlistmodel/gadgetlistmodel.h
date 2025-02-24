#pragma once
#include <QAbstractListModel>
#include <QJsonValue>
#include <QtQml/qqmlregistration.h>
#include <vector>

#include "baselist.h"

class GadgetListModel : public QAbstractListModel
{
private:
  Q_OBJECT
  QML_ELEMENT

  BaseList<QVariant> m_data {};

public:
  enum Role {
    DisplayRole = Qt::DisplayRole,
    DataRole = Qt::UserRole + 1,
  };
  Q_ENUM(Role)

  explicit GadgetListModel(QObject* parent = nullptr);

  [[nodiscard]] int rowCount(const QModelIndex &parent) const override;
  [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;
  bool setData(const QModelIndex &index, const QVariant &value, int role) override;
  [[nodiscard]] QHash<int, QByteArray> roleNames() const override;
  bool removeRows(int row, int count, const QModelIndex &parent) override;
  std::vector<QVariant>& internalData();
  void updateWholeModel(const std::vector<QVariant>& new_data);

  Q_INVOKABLE void append(const QVariant& value);
  Q_INVOKABLE void appendList(const QVariantList& value);
  Q_INVOKABLE QJSValue toArray();
  [[nodiscard]] Q_INVOKABLE QModelIndex findIndex(const QJSValue& predicate) const;
  Q_INVOKABLE void remove(const QJSValue& predicate);
  Q_INVOKABLE void forceRefresh();
  Q_INVOKABLE void clear();
};
