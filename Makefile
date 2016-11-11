MOC = qtchooser -run-tool=moc -qt=5
CXXFLAGS = -std=c++11 -pedantic -Wall -fPIC
CPPFLAGS = `pkg-config --cflags Qt5OpenGL`
LDFLAGS = -lGL `pkg-config --libs Qt5OpenGL`

.PHONY: all
all: sphere-tracing

sphere-tracing: sphere-tracing.o widget.o moc_widget.o
	$(CXX) -o $@ $^ $(LDFLAGS)

moc_%.cpp: %.h
	$(MOC) $< -o $@

.PHONY: clean
clean:
	rm -f *.o sphere-tracing
