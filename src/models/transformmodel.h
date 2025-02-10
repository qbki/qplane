#pragma once
#include <QIdentityProxyModel>
#include <QQmlEngine>

class TransformModel : public QIdentityProxyModel
{
private:
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QString role READ role WRITE setRole NOTIFY roleChanged)
  Q_PROPERTY(QJSValue map READ map WRITE setMap NOTIFY mapChanged)

  QJSValue m_map;
  QString m_role;

public:
  TransformModel(QObject *parent = nullptr);

  [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;
  [[nodiscard]] QJSValue map() const;
  void setMap(const QJSValue &value);

  [[nodiscard]] QString role() const;
  void setRole(const QString &value);

signals:
  void mapChanged();
  void roleChanged();
};
