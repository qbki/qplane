#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QUrl>

class EntityModel
{
private:
  Q_GADGET
  QML_NAMED_ELEMENT(entityModel)

  Q_PROPERTY(QString id READ id WRITE setId FINAL)
  Q_PROPERTY(QUrl path READ path WRITE setPath FINAL)
  Q_PROPERTY(bool isOpaque READ isOpaque WRITE setIsOpaque FINAL)

  QString m_id;
  QUrl m_path;
  bool m_isOpaque;

public:
  EntityModel();

  QString id() const;
  void setId(const QString &newId);

  QUrl path() const;
  void setPath(const QUrl &newPath);

  bool isOpaque() const;
  void setIsOpaque(bool newIsOpaque);
};

Q_DECLARE_METATYPE(EntityModel)

class EntityModelFactory : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  EntityModelFactory(QObject* parent = Q_NULLPTR);
  Q_INVOKABLE EntityModel create();
};

