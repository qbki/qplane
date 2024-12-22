#pragma once
#include <QObject>
#include <qqmlregistration.h>

/**
 * Contains fields that should have all entities.
 * This class should NOT be instantiated directly.
 */
class EntityBase
{
private:
  Q_GADGET
  Q_PROPERTY(QString id READ id WRITE setId FINAL)
  Q_PROPERTY(QString name READ name WRITE setName FINAL)

  QString m_id {""};
  QString m_name {""};

public:
  EntityBase() = default;
  EntityBase(const EntityBase&) = default;
  EntityBase(EntityBase&&) = delete;
  EntityBase& operator=(const EntityBase&) = default;
  EntityBase& operator=(EntityBase&&) = delete;
  virtual ~EntityBase() = default;

  [[nodiscard]] QString id() const;
  void setId(const QString& value);

  [[nodiscard]] QString name() const;
  void setName(const QString& value);
};
