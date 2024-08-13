#include <QApplication>
#include <QQmlApplicationEngine>
#include <QRect>

#include "types/entitymodel.h"
#include "types/placement.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);

  qRegisterMetaType<EntityModel>();
  qRegisterMetaType<Placement>();

  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);

  return app.exec();
}
