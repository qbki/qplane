#include <algorithm>

#include "transformmodel.h"

TransformModel::TransformModel(QObject *parent)
  : QIdentityProxyModel(parent)
{
}

QVariant TransformModel::data(const QModelIndex &index, int role) const
{
  const auto value = QIdentityProxyModel::data(index, role);
  if (m_map.isCallable()) {
    const auto roles = sourceModel()->roleNames();
    const auto engine = qmlEngine(this);
    QJSValueList args;
    args << engine->toScriptValue(value);
    if (roles.contains(role)) {
      args << engine->toScriptValue(roles[role]);
    } else {
      args << engine->toScriptValue(QVariant{});
    }
    return m_map.call(args).toVariant();
  }
  return value;
}

QJSValue TransformModel::map() const
{
  return m_map;
}

void TransformModel::setMap(const QJSValue &newMap)
{
  if (m_map.equals(newMap)) {
    return;
  }
  if (!newMap.isCallable()) {
    qmlEngine(this)->throwError(QString("Field map is not a function"));
    return;
  }
  m_map = newMap;
  emit mapChanged();
}

QString TransformModel::role() const
{
  return m_role;
}

void TransformModel::setRole(const QString &newRole)
{
  if (m_role == newRole) {
    return;
  }
  m_role = newRole;
  emit roleChanged();
}
