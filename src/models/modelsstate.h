#pragma once
#include <QAbstractListModel>
#include <QDir>
#include <QDirIterator>
#include <QStringList>
#include <QVector>

class ModelsState : public QAbstractListModel
{
  Q_OBJECT
  Q_PROPERTY(QString selectedModel READ selectedModel WRITE setSelectedModel NOTIFY selectedModelChanged FINAL)

private:
  QVariant m_header;
  QVector<QVariant> m_data;
  QString m_selectedModel {""};

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

  QString selectedModel() const;
  void setSelectedModel(const QString& value);

public slots:
  void populateFromDir(const QUrl& dirPath);

signals:
  void selectedModelChanged();
};
