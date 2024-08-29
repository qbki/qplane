#include <QApplication>
#include <QQmlApplicationEngine>
#include <QRect>

#include "types/entityactor.h"
#include "types/entitymodel.h"
#include "types/positionstrategymany.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);

  qRegisterMetaType<EntityActor>();
  qRegisterMetaType<EntityModel>();
  qRegisterMetaType<PositionStrategyMany>();

  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);

  return app.exec();
}
