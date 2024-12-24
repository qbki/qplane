#include <QDebug>
#include <ranges>
#include <tuple>

#include "jssetter.h"

JSStrictSetter::JSStrictSetter(QString where,
                               QJSValue candidateValue,
                               QJSValue defaultValue)
  : m_where(std::move(where))
  , m_candidateValue(std::move(candidateValue))
  , m_defaultValue(std::move(defaultValue))
{
}

JSStrictSetter
JSStrictSetter::nullable()
{
  m_validators.emplace_back([](const QJSValue& value) {
    auto isValid = value.isNull();
    auto message = isValid ? "" : "Value should be null type.";
    return std::make_tuple(isValid, message);
  });
  return *this;
}

JSStrictSetter
JSStrictSetter::number()
{
  m_validators.emplace_back([](const QJSValue& value) {
    auto isValid = value.isNumber();
    auto message = isValid ? "" : "Value should be Number type.";
    return std::make_tuple(isValid, message);
  });
  return *this;
}

QJSValue
JSStrictSetter::value()
{
  auto messages = m_validators
    | std::views::transform([&](const SetterFn& fn) { return fn(m_candidateValue); })
    | std::views::filter([](const std::tuple<bool, QString>& value) { return !std::get<0>(value); })
    | std::views::transform([](const std::tuple<bool, QString>& value) { return std::get<1>(value); });

  std::vector<QString> output_array;
  std::ranges::copy(messages, std::back_inserter(output_array));

  auto hasError = m_validators.size() == output_array.size();
  if (hasError) {
    for (const auto& message : output_array) {
      qWarning() << QString("%1: %2").arg(m_where, message);
    }
  }

  return hasError ? m_defaultValue : m_candidateValue;
}
