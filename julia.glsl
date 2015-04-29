#version 130

uniform sampler1D tex;
uniform vec2 c;
uniform int iter;

vec4 iterate(vec2 z, vec2 c, int max_iter) {
	vec2 dz = vec2(0.0, 0.0);
	int i;

	float mz2;// = dot(z, z);
	//float mdz2 = 1.0;
	for(i=0; i<max_iter; i++) {
		dz = 2.0 * vec2(z.x*dz.x - z.y*dz.y + 0.5,z.x*dz.y + z.y*dz.x);
		//mdz2 *= 4.0 * mz2;
	        z = c + vec2(z.x*z.x - z.y*z.y, 2.0 * z.x * z.y);

		mz2 = dot(z, z);
		if(mz2 > 100.0)
			break;
	}

	if (i == max_iter)
		return vec4(0.0, 0.0, 0.8, 0.0);
	else {
		float distance = sqrt (mz2 / dot(dz, dz)) * 0.5 * log(mz2);
		//float distance = sqrt (mz2 / mdz2) * 0.5 * log(mz2);
		float x = pow(distance, 0.3);
		float y = smoothstep(0.0, 1.0, x);
		return vec4(y, 0.5 * y, 0.0, 0.0);
	}
}

void main() {
	vec2 z;
	z.x = 3.0 * (gl_TexCoord[0].x - 0.5);
	z.y = 2.0 * (gl_TexCoord[0].y - 0.5);

#if 1
	gl_FragColor = iterate(z, c, iter);
#else
	int i;
	for(i=0; i<iter; i++) {
		float x = (z.x * z.x - z.y * z.y) + c.x;
		float y = (z.y * z.x + z.x * z.y) + c.y;

		if((x * x + y * y) > 4.0) break;
		z.x = x;
		z.y = y;
	}

	gl_FragColor = texture1D(tex, (i == iter ? 0.0 : float(i)) / 100.0);
#endif
}
