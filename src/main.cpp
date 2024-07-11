#include <QApplication>
#include <QQmlApplicationEngine>

#include "models/appstate.h"
#include "models/modelsstate.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);

  qmlRegisterType<ModelsState>("app", 1, 0, "ModelsState");
  qmlRegisterType<AppState>("app", 1, 0, "AppState");

  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);

  return app.exec();
}
