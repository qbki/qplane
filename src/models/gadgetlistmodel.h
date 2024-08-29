#pragma once
#include <QAbstractListModel>
#include <vector>

#include <src/types/entitymodel.h>

#include "baselist.h"

class GadgetListModel: public QAbstractListModel
{
  Q_OBJECT
  Q_PROPERTY(QString selectedModel READ selectedModel WRITE setSelectedModel NOTIFY selectedModelChanged)
  QML_ELEMENT

private:
  QString m_selectedModel {""};
  BaseList<QVariant> m_data {};

public:
  explicit GadgetListModel(QObject* parent = nullptr);

  int rowCount(const QModelIndex &parent) const;
  QVariant data(const QModelIndex &index, int role) const;
  bool setData(const QModelIndex &index, const QVariant &value, int role);
  std::vector<QVariant>& internalData();

  QString selectedModel() const;
  void setSelectedModel(const QString &value);

  void updateWholeModel(const std::vector<QVariant>& new_data);

  Q_INVOKABLE void append(const QVariant& value);
  Q_INVOKABLE QJSValue toArray();
  Q_INVOKABLE QModelIndex findIndex(const QJSValue& predicate) const;

signals:
  void selectedModelChanged();
};
