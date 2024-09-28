#include <QDir>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entitymodel.h"

QString EntityModel::id() const
{
  return m_id;
}

void EntityModel::set_id(const QString &new_id)
{
  m_id = new_id;
}

QUrl EntityModel::path() const
{
  return m_path;
}

void EntityModel::set_path(const QUrl &new_path)
{
  m_path = new_path;
}

bool EntityModel::is_opaque() const
{
  return m_is_opaque;
}

void EntityModel::set_is_opaque(bool new_is_opaque)
{
  m_is_opaque = new_is_opaque;
}

EntityModelFactory::EntityModelFactory(QObject* parent)
  : QObject(parent)
{
}

EntityModel EntityModelFactory::create()
{
  return {};
}

QJsonObject EntityModelFactory::toJson(const EntityModel &entity, const QUrl &projectDir)
{
  QJsonObject json;
  QDir dir(projectDir.toLocalFile());
  json["kind"] = "model";
  json["path"] = dir.relativeFilePath(entity.path().toLocalFile());
  json["is_opaque"] = entity.is_opaque();
  return json;
}

EntityModel EntityModelFactory::fromJson(const QString& id,
                                         const QJsonObject &json,
                                         const QUrl& projectDir)
{
  JsonValidator check(this, &json);
  const auto toUrl = [&](const QString& v) { return projectDir.resolved(v); };
  EntityModel entity;
  try {
    entity.set_id(id);
    entity.set_path(toUrl(check.string("path")));
    entity.set_is_opaque(check.boolean("is_opaque"));
  } catch(const std::runtime_error& error) {
    qmlEngine(this)->throwError(QJSValue::TypeError, error.what());
  }
  return entity;
}
