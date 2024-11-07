#pragma once
#include <QObject>
#include <QQmlEngine>
#include <cxxabi.h>
#include <memory>
#include <string>

void noop() {}

template<typename T>
std::string
demangledName()
{
  int status = 0;
  auto name = std::make_unique<char*>(
    abi::__cxa_demangle(typeid(T).name(), nullptr, nullptr, &status));
  std::string result { *name };
  switch (status) {
    case 0:
      noop();
      break;
    case -1:
      throw std::runtime_error("Demangle. A memory allocation "
                               "failure occurred.");
    case -2:
      throw std::runtime_error("Demangle. A mangled_name is not a valid name "
                               "under the C++ ABI mangling rules.");
    case -3:
      throw std::runtime_error("Demangle. One of the arguments is invalid.");
    default:
      throw std::runtime_error("Demangle. Unknown error.");
  }
  return result;
}

template<typename T>
T&
getQmlSingleton(const QObject* obj)
{
  return *qmlEngine(obj)->singletonInstance<T*>("app", demangledName<T>());
}

template<typename T>
T&
getQmlSingleton(const QObject& obj)
{
  return *getQmlSingleton<T>(&obj);
}
