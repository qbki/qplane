#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QRect>

#include "models/actionmanager/actionmanageritem.h"
#include "types/entityactor.h"
#include "types/entityboundaries.h"
#include "types/entitycamera.h"
#include "types/entitydirectionallight.h"
#include "types/entitymodel.h"
#include "types/entityparticles.h"
#include "types/entityweapon.h"
#include "types/positionstrategymany.h"
#include "types/positionstrategyvoid.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);

  qRegisterMetaType<ActionManagerItem>();
  qRegisterMetaType<EntityActor>();
  qRegisterMetaType<EntityBoundaries>();
  qRegisterMetaType<EntityCamera>();
  qRegisterMetaType<EntityDirectionalLight>();
  qRegisterMetaType<EntityModel>();
  qRegisterMetaType<EntityParticles>();
  qRegisterMetaType<EntityWeapon>();
  qRegisterMetaType<PositionStrategyMany>();
  qRegisterMetaType<PositionStrategyVoid>();

  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);

  return app.exec();
}
