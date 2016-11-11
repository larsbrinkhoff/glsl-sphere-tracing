#include "widget.h"

#include <QKeyEvent>

Widget::Widget(QWidget *parent) :
    QGLWidget(parent),
    timer(new QBasicTimer),
    program(new QGLShaderProgram)
{
  elapsed.start();
}

Widget::~Widget()
{
  delete timer; timer = 0;
  delete program; program = 0;
}

void Widget::timerEvent(QTimerEvent *e)
{
  Q_UNUSED(e);
  updateGL();
}

void Widget::initializeGL()
{
  initializeGLFunctions();

  if (!program->addShaderFromSourceFile(QGLShader::Fragment, "sphere-tracing.glsl"))
    close();
  if (!program->link())
    close();
  if (!program->bind())
    close();

  timer->start(1, this);
}

void Widget::resizeGL(int w, int h)
{
  glViewport(0, 0, w, h);
}

void Widget::paintGL()
{
  float t = elapsed.elapsed() / 10000.0;
  program->setUniformValue("time", t);

  glBegin(GL_QUADS);
  glTexCoord2f(0, 0);
  glVertex2f(-1, -1);
  glTexCoord2f(1, 0);
  glVertex2f(1, -1);
  glTexCoord2f(1, 1);
  glVertex2f(1, 1);
  glTexCoord2f(0, 1);
  glVertex2f(-1, 1);
  glEnd();
}

void Widget::keyPressEvent(QKeyEvent *key)
{
  switch(key->key()) {
  case Qt::Key_Escape:
  case Qt::Key_Q:
    exit(0);
  }
}
