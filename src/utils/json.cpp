#include <cmath>

#include "json.h"

namespace Json {

QJsonArray
to_array(const QVector3D &value)
{
  auto round = [](float value) -> double {
    constexpr double precision = 1'000'000.0;
    return std::round(value * precision) / precision;
  };
  return {round(value.x()), round(value.y()), round(value.z())};
}

}
