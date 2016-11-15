MOC = qtchooser -run-tool=moc -qt=5
EXTRA_CXXFLAGS += -std=c++11 -pedantic -Wall -fPIC
EXTRA_CPPFLAGS += `pkg-config --cflags Qt5OpenGL glesv2`
EXTRA_LDFLAGS += `pkg-config --libs Qt5OpenGL glesv2`

.PHONY: all
all: sphere-tracing

sphere-tracing: sphere-tracing.o widget.o moc_widget.o
	$(CXX) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS)

%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(EXTRA_CPPFLAGS) $(EXTRA_CXXFLAGS) -c -o $@ $^

moc_%.cpp: %.h
	$(MOC) $< -o $@

install:
	install -m 755 sphere-tracing $(BINDIR)
	install -m 644 sphere-tracing.glsl $(BINDIR)
	install -m 644 vshader.glsl $(BINDIR)

.PHONY: clean
clean:
	rm -f *.o sphere-tracing
