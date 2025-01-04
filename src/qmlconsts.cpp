#include "consts.h"
#include "qmlconsts.h"

QmlConsts::QmlConsts(QObject* parent)
  : QObject{ parent }
{
}

QString QmlConsts::defaultSceneLayerId() const
{
  return DEFAULT_SCENE_LAYER_ID;
}
