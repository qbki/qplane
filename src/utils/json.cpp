#include <cmath>

#include "json.h"

namespace Json {

QJsonArray
to_array(const QVector3D &value)
{
  auto round = [](float value) -> double {
    return std::round(value * 1000000.0) / 1000000.0;
  };
  return {round(value.x()), round(value.y()), round(value.z())};
}

}
