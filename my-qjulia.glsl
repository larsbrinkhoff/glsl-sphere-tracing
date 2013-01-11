uniform sampler1D tex;
uniform vec2 center;
uniform float view_distance;
uniform float view_angle1;
uniform float view_angle2;
uniform vec4 julia_c;
uniform int iter;

vec4 qmul (vec4 q1, vec4 q2)
{
   vec4 r;
   r.x = q1.x*q2.x - dot(q1.yzw, q2.yzw);
   r.yzw = q1.x*q2.yzw + q2.x*q1.yzw + cross(q1.yzw, q2.yzw);
   return r;
}

vec4 qsqr (vec4 q)
{
   vec4 r;
   r.x = q.x*q.x - dot(q.yzw, q.yzw);
   r.yzw = 2*q.x*q.yzw;
   return r;
}

int iterate (inout vec4 z, out vec4 dz, vec4 c, int max_iter)
{
	dz = vec4(1.0, 0.0, 0.0, 0.0);

	for (int i = 0; i < max_iter; i++)
	{
		if (dot(z, z) > 1000.0)
			return i;

		dz = 2.0 * qmul(z, dz) + vec4(1.0, 0.0, 0.0, 0.0);
		z = qsqr(z) + c;
	}
	return max_iter;
}

vec3 julia_normal(vec3 p, vec4 c)
{
	vec2 e = vec2(0.001, 0.0);
	vec4 z = vec4(p, 0.0);
	vec4 x1 = z - e.xyyy;
	vec4 x2 = z + e.xyyy;
	vec4 y1 = z - e.yxyy;
	vec4 y2 = z + e.yxyy;
	vec4 z1 = z - e.yyxy;
	vec4 z2 = z + e.yyxy;

	for (int i = 0; i < 100; i++) {
		x1 = qsqr(x1) + c;
		x2 = qsqr(x2) + c;
		y1 = qsqr(y1) + c;
		y2 = qsqr(y2) + c;
		z1 = qsqr(z1) + c;
		z2 = qsqr(z2) + c;
	}

	return normalize (vec3(length(x2) - length(x1),
			       length(y2) - length(y1),
			       length(z2) - length(z1)));
}

bool intersect_qjulia (inout vec3 rp, vec3 rd, vec4 c, int max_iter, out vec3 normal)
{
	vec4 z, dz;
	float z2, distance;

	do {
		z = vec4(rp, 0.0);
		int i = iterate (z, dz, c, max_iter);
		

		z2 = dot(z, z);
		distance = sqrt (z2 / dot(dz, dz)) * 0.5 * log(z2);
		if (distance < 0.001) {
			//normal = normalize(dz.xyz);
			//normal = julia_normal(rp, c);
			normal = vec3(float(i) / float(max_iter));
			return true;
		}

		rp += distance * rd;
	} while (dot (rp, rp) < 4.0);

	return false;
}

bool intersect_sphere (inout vec3 rp, vec3 rd, float radius)
{
   float B, C, E, d, t0, t1, t;

   B = 2.0 * dot( rp, rd );
   C = dot( rp, rp ) - radius * radius;
   E = B*B - 4.0*C;
   if (E < 0.0)
     return false;

   d = sqrt( E );
   //t0 = ( -B + d ) * 0.5;
   t1 = ( -B - d ) * 0.5;
   //t = min( t0, t1 );
   rp += t1 * rd;
   return true;
}

/*
	vec4 z = vec4(c, 0.0, 0.0), dz;
	vec4 qc = vec4(-.5, .1, 0.0, 0.0);
	iterate(z, dz, qc, max_iter);

		float z2 = dot(z, z);
		float distance = sqrt (z2 / dot(dz, dz)) * 0.5 * log(z2);
		float x = pow(distance, 0.1);
		float y = max(min(x, 1.0), 0.0);
		return vec4(y, 0.5 * y, 0.0, 0.0);
*/

void main() {
	vec2 screen = vec2(6.0, 4.5);
	//vec4 julia_c = vec4(-.5, .1, 0.0, 0.0);
	//vec4 julia_c = vec4(-1.47409435510635, -0.00043243408203125, 0.00043243408203125, 0.0);
	//vec4 julia_c = vec4(-0.817795, -0.2000035, 0.0, 0.0);
	//vec4 julia_c = vec4(-0.817795, -0.2000035, -0.2000035, 0.0);
	vec4 julia_c = vec4(-0.75, 0.11, 0.0, 0.0);

	//vec3 rp = vec3(center, scale);
	vec3 rp;
	rp.x = sin(view_angle1) * sin(view_angle2);
	rp.y = cos(view_angle1) * sin(view_angle2);
	rp.z = -cos(view_angle2);
	rp *= 10.0 * view_distance;

	vec3 px = 4.0 * normalize(cross (rp, vec3(0.0, 1.0, 0.0)));
	vec3 py = 3.0 * normalize(cross (rp, px));
	vec3 pz = cross(px, py);

	// vec3 rd = vec3(screen * (gl_TexCoord[0].xy - 0.5), 0.0);
	vec3 rd = (gl_TexCoord[0].x - 0.5) * px +
		  (gl_TexCoord[0].y - 0.5) * py +
	          rp * (view_distance - 3.0) / view_distance;
	rd = normalize(rd - rp);

	gl_FragColor = vec4(rd.xy, 0.0, 1.0);

	if (intersect_sphere (rp, rd, 2.1))
	{
		gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
		vec3 normal;
		if (intersect_qjulia(rp, rd, julia_c, iter, normal)) {
			//gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
			//gl_FragColor = vec4(rp.z * 10.0, 1.0, 0.0, 1.0);
			float color = normal.x; //dot(normal, vec3(1.0, 1.0, -1.0));
			gl_FragColor = vec4(color, color, color, 1.0);
		}
/*		float distance = intersect_qjulia(rp, rd, c, iter);
		float y1 = max(min(distance, 1.0), 0.0);
		float y2 = max(min(0.1*distance, 1.0), 0.0);
		float y3 = max(min(0.01*distance, 1.0), 0.0);
		gl_FragColor = vec4(y1, y2, y3, 1.0);*/
	}
}
