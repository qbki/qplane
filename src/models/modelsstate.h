#pragma once
#include <QAbstractListModel>
#include <QDir>
#include <QDirIterator>
#include <QStringList>
#include <QVector>

class ModelsState : public QAbstractListModel
{
  Q_OBJECT

private:
  QVariant _header;
  QVector<QVariant> _data;

public:
  explicit ModelsState(QObject* parent = nullptr);

  QVariant headerData(int section,
                      Qt::Orientation orientation,
                      int role = Qt::DisplayRole) const override;

  bool setHeaderData(int section,
                     Qt::Orientation orientation,
                     const QVariant& value,
                     int role = Qt::EditRole) override;

  int rowCount(const QModelIndex& parent = QModelIndex()) const override;

  QVariant data(const QModelIndex& index,
                int role = Qt::DisplayRole) const override;

  bool setData(const QModelIndex& index,
               const QVariant& value,
               int role = Qt::EditRole) override;

  Qt::ItemFlags flags(const QModelIndex& index) const override;

public slots:
  void populateFromDir(const QUrl& dirPath);
};
