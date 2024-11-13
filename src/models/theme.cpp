#include "theme.h"

Theme::Theme(QObject* parent)
  : QObject{ parent }
{
}

int Theme::spacing(float value)
{
  return static_cast<int>(SPACING * value);
}

double Theme::sceneOpacity() const
{
  return m_sceneOpacity;
}
