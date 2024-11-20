#include <QClipboard>
#include <QGuiApplication>

#include "clipboard.h"

Clipboard::Clipboard(QObject* parent)
  : QObject{ parent }
{
}

void Clipboard::copy(const QString &text) const
{
  auto clipboard = QGuiApplication::clipboard();
  clipboard->setText(text);
}
