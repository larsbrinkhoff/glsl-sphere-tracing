#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>
#include "util.h"

void draw(void);
void idle_handler(void);
void key_handler(unsigned char key, int x, int y);
void bn_handler(int bn, int state, int x, int y);
void mouse_handler(int x, int y);

unsigned int prog;
float julia_c[4] = { -.5, .1, 0.0, 0.0 };
float view_angle1 = 0.0;
float view_angle2 = 0.0;
float view_distance = 6.0;
int iter = 70;
const float zoom_factor = 0.025;

int main(int argc, char **argv) {
	/* initialize glut */
	glutInitWindowSize(800, 600);
	
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
	glutCreateWindow("Mindlapse :: GLSL Mandelbrot");

	glutDisplayFunc(draw);
	glutIdleFunc(idle_handler);
	glutKeyboardFunc(key_handler);
	glutMouseFunc(bn_handler);
	glutMotionFunc(mouse_handler);

	/* load and set the mandelbrot shader */
	if(!(prog = setup_shader("sphere-tracing.glsl"))) {
		return EXIT_FAILURE;
	}
	set_uniform1i(prog, "iter", iter);

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

	set_uniform4f(prog, "julia_c", julia_c[0], julia_c[1], julia_c[2], julia_c[3]);
	set_uniform1f(prog, "view_angle1", view_angle1);
	set_uniform1f(prog, "view_angle2", view_angle2);
	set_uniform1f(prog, "view_distance", view_distance);
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

	case '=':
		if(1) {
			iter += 10;
		} else {
	case '-':
			iter -= 10;
			if(iter < 0) iter = 0;
		}
		printf("iterations: %d\n", iter);
		set_uniform1i(prog, "iter", iter);
		break;

	default:
		break;
	}
	glutPostRedisplay();
}

int which_bn;
float px, py;

void bn_handler(int bn, int state, int x, int y) {
	int xres = glutGet(GLUT_WINDOW_WIDTH);
	int yres = glutGet(GLUT_WINDOW_HEIGHT);
	px = 2.0 * ((float)x / (float)xres - 0.5);
	py = 2.0 * ((float)y / (float)yres - 0.5);
	which_bn = bn;

	if(which_bn == 3) {
	        view_distance += 0.1;
	} else if(which_bn == 4) {
	        view_distance -= 0.1;
	}
	glutPostRedisplay();
}

void mouse_handler(int x, int y) {
	int xres = glutGet(GLUT_WINDOW_WIDTH);
	int yres = glutGet(GLUT_WINDOW_HEIGHT);
	float fx = 3.14 * (float)x / (float)xres - 1.0;
	float fy = 3.14 * (float)y / (float)yres - 1.0;

	if(which_bn == 1) {
	  view_angle1 = fy;
	  view_angle2 = -fx;
	} else if(which_bn == 0) {
	  /*scale *= (fy - py < 0.0) ? 1 - zoom_factor : 1 + zoom_factor;*/
	}

	px = fx;
	py = fy;
	glutPostRedisplay();
}