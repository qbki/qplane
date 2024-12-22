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
EntityModel::setPath(const QUrl& value)
{
  m_path = value;
}

bool
EntityModel::isOpaque() const
{
  return m_isOpaque;
}

void
EntityModel::setIsOpaque(bool value)
{
  m_isOpaque = value;
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
EntityModelFactory::toJson(const EntityModel& entity, const QUrl& projectDir)
{
  QJsonObject json;
  QDir dir(projectDir.toLocalFile());
  json["kind"] = "model";
  json["name"] = entity.name();
  json["path"] = dir.relativeFilePath(entity.path().toLocalFile());
  json["is_opaque"] = entity.isOpaque();
  return json;
}

EntityModel
EntityModelFactory::fromJson(const QString& id,
                             const QJsonObject& json,
                             const QUrl& projectDir)
{
  const auto toUrl = [&](const QString& v) { return projectDir.resolved(v); };
  return JsonValidator(this, &json, id)
    .handle<EntityModel>([&](auto& check, auto& entity) {
      entity.setId(id);
      entity.setName(check.string("name"));
      entity.setPath(toUrl(check.string("path")));
      entity.setIsOpaque(check.boolean("is_opaque"));
    });
}
