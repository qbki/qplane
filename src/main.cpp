#include <QApplication>
#include <QQmlApplicationEngine>
#include <QRect>

// #include "models/appstate.h"
// #include "models/modelentitystate.h"
#include "types/entitymodel.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);

  qRegisterMetaType<EntityModel>();

  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);

  return app.exec();
}
