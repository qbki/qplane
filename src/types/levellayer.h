#pragma once
#include "entitybase.h"

class LevelLayer : public EntityBase
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(levelLayer)

  Q_PROPERTY(bool isVisible READ isVisible WRITE setIsVisible FINAL)

  bool m_isVisible {true};

public:
  LevelLayer() = default;

  [[nodiscard]] bool isVisible() const;
  void setIsVisible(bool value);

  [[nodiscard]] Q_INVOKABLE LevelLayer copy() const;
};

Q_DECLARE_METATYPE(LevelLayer)

class LevelLayerFactory : public QObject
{
private:
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  LevelLayerFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE LevelLayer create();
  Q_INVOKABLE QJsonObject toJson(const LevelLayer& entity);
  Q_INVOKABLE LevelLayer fromJson(const QJsonObject& json);
};
