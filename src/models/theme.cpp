#include "theme.h"

const QColor Theme::ERROR_COLOR = QColor::fromString("#ff1111");

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

QColor Theme::errorColor() const
{
  return ERROR_COLOR;
}
