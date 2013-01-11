#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>
#include "util.h"

void draw(void);
void key_handler(unsigned char key, int x, int y);
void mouse_handler(int x, int y);

unsigned int prog;
float cx, cy;
int iter = 60;
int interactive = 0;

int main(int argc, char **argv) {
	void *img;
	
	glutInitWindowSize(800, 600);
	
	/* initialize glut */
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
	glutCreateWindow("Mindlapse :: GLSL Julia");

	glutDisplayFunc(draw);
	glutIdleFunc(draw);
	glutKeyboardFunc(key_handler);
	glutMotionFunc(mouse_handler);

	/* load the 1D palette texture */
	glBindTexture(GL_TEXTURE_1D, 1);
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	
	if(!(img = load_image("pal.ppm", 0, 0))) {
		return EXIT_FAILURE;
	}
	glTexImage1D(GL_TEXTURE_1D, 0, 4, 256, 0, GL_BGRA, GL_UNSIGNED_BYTE, img);
	free(img);

	glEnable(GL_TEXTURE_1D);

	/* load and set the julia shader */
	if(!(prog = setup_shader("julia.glsl"))) {
		return EXIT_FAILURE;
	}
	set_uniform1i(prog, "iter", iter);

	glutMainLoop();
	return 0;
}

void draw(void) {
	if(!interactive) {
		float t = (float)get_msec() / 10000.0;
		cx = (sin(cos(t / 10) * 10) + cos(t * 2.0) / 4.0 + sin(t * 3.0) / 6.0) * 0.8;
		cy = (cos(sin(t / 10) * 10) + sin(t * 2.0) / 4.0 + cos(t * 3.0) / 6.0) * 0.8;
	}
	set_uniform2f(prog, "c", cx, cy);

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

void key_handler(unsigned char key, int x, int y) {
	switch(key) {
	case 27:
	case 'q':
	case 'Q':
		exit(0);
		break;

	case ' ':
		interactive = !interactive;
		break;

	case '=':
		if(1) {
			iter += 10;
		} else {
	case '-':
			iter -= 10;
		}
		printf("iterations: %d\n", iter);
		set_uniform1i(prog, "iter", iter);
		break;
	}
}

#define PX_TO_RE(x)		(1.5 * ((x) - xres / 2) / (0.5 * xres))
#define PY_TO_IM(y)		(((y) - yres / 2) / (0.5 * yres))
void mouse_handler(int x, int y) {
	int xres = glutGet(GLUT_WINDOW_WIDTH);
	int yres = glutGet(GLUT_WINDOW_HEIGHT);
	cx = PX_TO_RE(x);
	cy = PY_TO_IM(yres - y);
}
