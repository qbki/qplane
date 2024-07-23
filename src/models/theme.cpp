#include "theme.h"

Theme::Theme(QObject* parent)
  : QObject{ parent }
{
}

int Theme::spacing(float value)
{
  return SPACING * value;
}
