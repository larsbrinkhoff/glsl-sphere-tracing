CC = gcc
CFLAGS = -std=c89 -pedantic -Wall
LDFLAGS = -L/usr/lib64/nvidia -L/usr/X11R6/lib -lGL -lGLU -lglut -lm

.PHONY: all
all: sphere-tracing

sphere-tracing: sphere-tracing.o util.o
	$(CC) -o $@ $^ $(LDFLAGS)

.PHONY: clean
clean:
	rm -f *.o sphere-tracing
