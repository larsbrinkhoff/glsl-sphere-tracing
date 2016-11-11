#include "widget.h"

#include <QKeyEvent>

struct VertexData
{
    QVector3D position;
    QVector2D texCoord;
};

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

  if (!program->addShaderFromSourceFile(QGLShader::Vertex, "vshader.glsl"))
    close();
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

  glGenBuffers(2, vbo);

  VertexData vertices[] = {
    {QVector3D(-1.0, -1.0,  1.0), QVector2D(0.0, 0.0)},
    {QVector3D( 1.0, -1.0,  1.0), QVector2D(0.33, 0.0)},
    {QVector3D(-1.0,  1.0,  1.0), QVector2D(0.0, 0.5)},
    {QVector3D( 1.0,  1.0,  1.0), QVector2D(0.33, 0.5)}
  };
  GLushort indices[] = {
    0,  1,  2,  3,  3,     // Face 0 - triangle strip ( v0,  v1,  v2,  v3)
  };

  glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
  glBufferData(GL_ARRAY_BUFFER, sizeof vertices, vertices, GL_STATIC_DRAW);

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[1]);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof indices, indices, GL_STATIC_DRAW);

  glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[1]);
  int vertexLocation = program->attributeLocation("a_position");
  program->enableAttributeArray(vertexLocation);
  glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData), NULL);
  glDrawElements(GL_TRIANGLE_STRIP, 5, GL_UNSIGNED_SHORT, 0);
}

void Widget::keyPressEvent(QKeyEvent *key)
{
  switch(key->key()) {
  case Qt::Key_Escape:
  case Qt::Key_Q:
    exit(0);
  }
}
