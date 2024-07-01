#include <QApplication>

#include "mainwindow/mainwindow.h"

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);
  MainWindow window;
  window.setWindowTitle("First Qt application");
  window.resize(800, 600);
  window.show();
  return app.exec();
}
