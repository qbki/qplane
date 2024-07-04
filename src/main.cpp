#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  engine.loadFromModule("app", "MainWindow");
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QApplication::quit);
  return app.exec();
}
