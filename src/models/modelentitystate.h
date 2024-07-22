#pragma once
#include <QAbstractListModel>
#include <vector>

#include <src/types/entitymodel.h>

#include "baselist.h"

class ModelEntityState : public QAbstractListModel
{
  Q_OBJECT
  Q_PROPERTY(QString selectedModel READ selectedModel WRITE setSelectedModel NOTIFY selectedModelChanged FINAL)
  QML_ELEMENT

private:
  QString m_selectedModel {""};
  BaseList<EntityModel> m_data {};

public:
  explicit ModelEntityState(QObject* parent = nullptr);

  int rowCount(const QModelIndex &parent) const;
  QVariant data(const QModelIndex &index, int role) const;
  bool setData(const QModelIndex &index, const QVariant &value, int role);
  std::vector<EntityModel>& internalData();

  QString selectedModel() const;
  void setSelectedModel(const QString &value);

signals:
  void selectedModelChanged();

public slots:
  QModelIndex findIndexById(const QString& id);
  void populateFromDir(const QUrl& dirPath);
};
