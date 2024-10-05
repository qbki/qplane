#include <QApplication>
#include <QQmlApplicationEngine>
#include <QRect>

#include "types/entityactor.h"
#include "types/entitydirectionallight.h"
#include "types/entitymodel.h"
#include "types/entityparticles.h"
#include "types/entityweapon.h"
#include "types/positionstrategymany.h"
#include "types/positionstrategyvoid.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);

  qRegisterMetaType<EntityActor>();
  qRegisterMetaType<EntityModel>();
  qRegisterMetaType<EntityParticles>();
  qRegisterMetaType<EntityWeapon>();
  qRegisterMetaType<EntityDirectionalLight>();
  qRegisterMetaType<PositionStrategyMany>();
  qRegisterMetaType<PositionStrategyVoid>();

  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);

  return app.exec();
}
