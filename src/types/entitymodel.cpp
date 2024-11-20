#include <QDir>
#include <QJsonObject>

#include "src/utils/jsonvalidator.h"

#include "entitymodel.h"

QUrl
EntityModel::path() const
{
  return m_path;
}

void
EntityModel::set_path(const QUrl &new_path)
{
  m_path = new_path;
}

bool
EntityModel::is_opaque() const
{
  return m_is_opaque;
}

void
EntityModel::set_is_opaque(bool new_is_opaque)
{
  m_is_opaque = new_is_opaque;
}

EntityModel
EntityModel::copy() const
{
  return *this;
}

EntityModelFactory::EntityModelFactory(QObject* parent)
  : QObject(parent)
{
}

EntityModel
EntityModelFactory::create()
{
  return {};
}

QJsonObject
EntityModelFactory::toJson(const EntityModel &entity, const QUrl &projectDir)
{
  QJsonObject json;
  QDir dir(projectDir.toLocalFile());
  json["kind"] = "model";
  json["name"] = entity.name();
  json["path"] = dir.relativeFilePath(entity.path().toLocalFile());
  json["is_opaque"] = entity.is_opaque();
  return json;
}

EntityModel
EntityModelFactory::fromJson(const QString& id,
                             const QJsonObject &json,
                             const QUrl& projectDir)
{
  const auto toUrl = [&](const QString& v) { return projectDir.resolved(v); };
  return JsonValidator(this, &json, id)
    .handle<EntityModel>([&](auto& check, auto& entity) {
      entity.set_id(id);
      entity.set_name(check.string("name"));
      entity.set_path(toUrl(check.string("path")));
      entity.set_is_opaque(check.boolean("is_opaque"));
    });
}
