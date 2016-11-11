#include <QtWidgets/QApplication>

#include "widget.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    a.setApplicationName("cube");
    a.setApplicationVersion("0.1");

    Widget w;
    w.resize(800, 600);
    w.show();
    return a.exec();
}
