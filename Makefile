obj = image_ppm.o sdr.o timer.o

CC = gcc
CFLAGS = -std=c89 -pedantic -Wall
LDFLAGS = -L/usr/lib64/nvidia -L/usr/X11R6/lib -lGL -lGLU -lglut

.PHONY: all
all: mbrot julia qjulia

mbrot: mbrot.o $(obj)
	$(CC) -o $@ mbrot.o $(obj) $(LDFLAGS)

julia: julia.o $(obj)
	$(CC) -o $@ julia.o $(obj) $(LDFLAGS)

qjulia: qjulia.o $(obj)
	$(CC) -o $@ qjulia.o $(obj) $(LDFLAGS)

.PHONY: clean
clean:
	rm -f *.o mbrot julia qjulia
