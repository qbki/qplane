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
  explicit GadgetListModel(QObject* parent = nullptr);

  int rowCount(const QModelIndex &parent) const override;
  QVariant data(const QModelIndex &index, int role) const override;
  bool setData(const QModelIndex &index, const QVariant &value, int role) override;
  std::vector<QVariant>& internalData();
  void updateWholeModel(const std::vector<QVariant>& new_data);

  Q_INVOKABLE void append(const QVariant& value);
  Q_INVOKABLE void appendList(const QVariantList& value);
  Q_INVOKABLE QJSValue toArray();
  Q_INVOKABLE QModelIndex findIndex(const QJSValue& predicate) const;
  Q_INVOKABLE void remove(const QJSValue& predicate);
};
