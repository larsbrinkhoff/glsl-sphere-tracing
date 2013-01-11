uniform sampler1D tex;
uniform vec2 center;
uniform float scale;
uniform int iter;

vec4 foo(vec2 c) {
	vec2 z = c;
	int i;

	for(i=0; i<iter; i++) {
		if(dot(z, z) > 4.0) break;
	        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
	}

	return texture1D(tex, (i == iter ? 0.0 : float(i)) / 100.0);
}

const int n = 2;

void main() {
	vec2 c;

	c = scale * (gl_TexCoord[0].xy - 0.5) - center;
	c.x *= 1.3333;

	vec4 color = 0;
	for (int i = 0; i < n; i++) {
		c.y = (gl_TexCoord[0].y - 0.5) * scale - center.y;
		for (int j = 0; j < n; j++) {
			color += foo(c);
			c.y += scale / 600.0 / n;
		}
		c.x += scale / 800.0 / n;
	}

	color /= n * n;
	gl_FragColor = color;
}
