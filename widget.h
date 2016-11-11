#ifndef WIDGET_H
#define WIDGET_H

#include <QTime>
#include <QBasicTimer>
#include <QtOpenGL/QGLWidget>
#include <QtOpenGL/QGLFunctions>
#include <QtOpenGL/QGLShaderProgram>

class Widget : public QGLWidget, protected QGLFunctions
{
    Q_OBJECT
public:
    explicit Widget(QWidget *parent = 0);
    virtual ~Widget();

signals:

public slots:

protected:
    void timerEvent(QTimerEvent *e);
    void initializeGL();
    void resizeGL(int w, int h);
    void paintGL();
    void initShaders();
    virtual void keyPressEvent(QKeyEvent *);

private:
    GLuint vbo[2];
    QTime elapsed;
    QBasicTimer *timer;
    QGLShaderProgram *program;
};

#endif // WIDGET_H
