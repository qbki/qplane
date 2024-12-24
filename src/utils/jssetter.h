#pragma once
#include <QJSValue>

class JSStrictSetter
{
public:
  using SetterFn = std::function<std::tuple<bool, QString>(const QJSValue&)>;

  explicit JSStrictSetter(QString where,
                          QJSValue candidateValue = QJSValue::NullValue,
                          QJSValue defaultValue = QJSValue::NullValue);

  JSStrictSetter nullable();
  JSStrictSetter number();
  QJSValue value();

private:
  bool isNull(const QJSValue& value);
  bool isNumber(const QJSValue& value);

  QString m_where {""};
  QJSValue m_defaultValue {QJSValue::NullValue};
  QJSValue m_candidateValue {QJSValue::NullValue};
  std::vector<SetterFn> m_validators {};
};
