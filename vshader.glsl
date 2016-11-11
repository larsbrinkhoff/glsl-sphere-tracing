#ifdef GL_ES
precision mediump int;
precision mediump float;
#endif

attribute vec4 a_position;
varying vec2 v_texcoord;

void main()
{
    gl_Position = a_position;
}