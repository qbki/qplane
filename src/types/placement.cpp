#include "placement.h"

Placement::Placement() {}

PlacementFactory::PlacementFactory(QObject *parent)
  : QObject(parent)
{
}

Placement PlacementFactory::create()
{
  return {};
}

QString Placement::id() const
{
  return m_id;
}

void Placement::setId(const QString &newId)
{
  m_id = newId;
}

QString Placement::behaviour() const
{
  return m_behaviour;
}

void Placement::setBehaviour(const QString& newBehaviour)
{
  m_behaviour = newBehaviour;
}

const std::vector<QVector3D>& Placement::getPositions() const
{
  return m_positions;
}

QVariant Placement::getQmlPositions() const
{
  QVariantList result;
  std::ranges::copy(m_positions, std::back_inserter(result));
  return result;
}

void Placement::pushPosition(const QVector3D &position)
{
  m_positions.push_back(position);
}
