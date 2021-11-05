#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>
#include "util.h"

void draw(void);
void idle_handler(void);
void key_handler(unsigned char key, int x, int y);

unsigned int prog;

int main(int argc, char **argv) {
	/* initialize glut */
	glutInitWindowSize(800, 600);
	
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
	glutCreateWindow("Sphere Tracing");

	glutDisplayFunc(draw);
	glutIdleFunc(idle_handler);
	glutKeyboardFunc(key_handler);

	/* load and set the mandelbrot shader */
	if(!(prog = setup_shader("sphere-tracing.glsl"))) {
		return EXIT_FAILURE;
	}

	glutPostRedisplay();
	glutMainLoop();
	return 0;
}

int frames = 0;
float last_time = 0;

void draw(void) {
        float t = glutGet(GLUT_ELAPSED_TIME) / 1000.0 - last_time;
	frames++;
	if (t > 10) {
	  printf ("FPS = %f\n", frames / t);
	  frames = 0;
	  last_time += t;
	}

	set_uniform1f(prog, "time", glutGet(GLUT_ELAPSED_TIME)/10000.0);

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

	glutSwapBuffers();
}

void idle_handler(void) {
  glutPostRedisplay();
}

void key_handler(unsigned char key, int x, int y) {
	switch(key) {
	case 27:
	case 'q':
	case 'Q':
		exit(0);
	}
	glutPostRedisplay();
}
