#pragma once
#include <QIdentityProxyModel>
#include <QQmlEngine>

class TransformModel : public QIdentityProxyModel
{
  Q_OBJECT
  Q_PROPERTY(QString role READ role WRITE setRole NOTIFY roleChanged)
  Q_PROPERTY(QJSValue map READ map WRITE setMap NOTIFY mapChanged)
  QML_ELEMENT

public:
  TransformModel(QObject *parent = nullptr);

  [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;
  [[nodiscard]] QJSValue map() const;
  void setMap(const QJSValue &newMap);

  [[nodiscard]] QString role() const;
  void setRole(const QString &newRole);

signals:
  void mapChanged();
  void roleChanged();

private:
  QJSValue m_map;
  QString m_role;
};
