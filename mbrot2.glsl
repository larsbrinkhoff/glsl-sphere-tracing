uniform sampler1D tex;
uniform vec2 center;
uniform float scale;
uniform int iter;

vec4 foo(vec2 c, int max_iter) {
	vec2 z = c;
	vec2 dz = vec2(1.0, 0.0);
	int i;

	float z2;
	for(i=0; i<max_iter; i++) {
		dz = 2.0 * vec2(z.x*dz.x - z.y*dz.y + 0.5,z.x*dz.y + z.y*dz.x);
	        z = c + vec2(z.x*z.x - z.y*z.y, 2.0 * z.x * z.y);

		z2 = dot(z, z);
		if(z2 > 100.0)
			break;
	}

	if (i == max_iter)
		return vec4(0.0, 0.0, 0.5, 0.0);
	else {
		float distance = sqrt (z2 / dot(dz, dz)) * 0.5 * log(z2);
		float x = pow(distance, 0.1);
		float y = max(min(x, 1.0), 0.0);
		return vec4(y, 0.5 * y, 0.0, 0.0);
	}
	//return texture1D(tex, i == max_iter ? 0.0 : .3 / pow(distance,.1));


	/*
	distance gradient =
		z * (dz - z ddz log z) / (c dz^2) + log c
	*/
}

const int n = 2;

void main() {
	vec2 c;

	c = scale * (gl_TexCoord[0].xy - 0.5) - center;
	c.x *= 1.3333;

	int max_iter = int(7.0 * pow(10.0, float(iter) / 70.0));
	vec4 color = 0;
	for (int i = 0; i < n; i++) {
		c.y = (gl_TexCoord[0].y - 0.5) * scale - center.y;
		for (int j = 0; j < n; j++) {
			color += foo(c, max_iter);
			c.y += scale / 600.0 / n;
		}
		c.x += scale / 800.0 / n;
	}

	color /= n * n;
	gl_FragColor = color;
}
