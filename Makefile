obj = image_ppm.o sdr.o timer.o

CC = gcc
CFLAGS = -std=c89 -pedantic -Wall
LDFLAGS = -L/usr/lib64/nvidia -L/usr/X11R6/lib -lGL -lGLU -lglut -lm

.PHONY: all
all: qjulia

qjulia: qjulia.o $(obj)
	$(CC) -o $@ qjulia.o $(obj) $(LDFLAGS)

.PHONY: clean
clean:
	rm -f *.o qjulia
