#version 100

precision mediump float;

const vec2 resolution = vec2(800.0, 600.0);
const int max_iter = 10;
const float bailout = 4.0;
uniform float time;

vec4 cccc;
mat4 transform;
mat4 inverse_transform;

vec4 qmul (const vec4 q1, const vec4 q2)
{
   vec4 r;
   r.x = q1.x*q2.x - dot(q1.yzw, q2.yzw);
   r.yzw = q1.x*q2.yzw + q2.x*q1.yzw + cross(q1.yzw, q2.yzw);
   return r;
}

vec4 qsqr (const vec4 q)
{
   vec4 r;
   r.x = q.x*q.x - dot(q.yzw, q.yzw);
   r.yzw = 2.0*q.x*q.yzw;
   return r;
}

mat4 rotate_xz(float x)
{
    return mat4(cos(x), 0.0, -sin(x), 0.0,
                   0.0, 1.0,     0.0, 0.0,
                sin(x), 0.0,  cos(x), 0.0,
                   0.0, 0.0,     0.0, 1.0);
}

mat4 rotate_xy(float x)
{
    return mat4(cos(x), -sin(x), 0.0, 0.0,
                sin(x),  cos(x), 0.0, 0.0,
                   0.0,     0.0, 1.0, 0.0,
                   0.0,     0.0, 0.0, 1.0);
}

vec3 rotate(const vec3 p, mat4 m)
{
   return vec3(m * vec4(p, 1.0));
}

vec3 calcNormal(in vec3 p)
{
    vec3 normal;

    vec4 c = cccc;

    vec4 nz,ndz,dz[4];

    vec4 z=vec4(p,0.0); //(c.y+c.x)*.3);

    dz[0]=vec4(1.0,0.0,0.0,0.0);
    dz[1]=vec4(0.0,1.0,0.0,0.0);
    dz[2]=vec4(0.0,0.0,1.0,0.0);
  //dz[3]=vec4(0.0,0.0,0.0,1.0);

    for(int i=0;i<max_iter;i++)
    {
        vec4 mz = vec4(z.x,-z.y,-z.z,-z.w);
        // derivative
        dz[0]=vec4(dot(mz,dz[0]),z.x*dz[0].yzw+dz[0].x*z.yzw);
        dz[1]=vec4(dot(mz,dz[1]),z.x*dz[1].yzw+dz[1].x*z.yzw);
        dz[2]=vec4(dot(mz,dz[2]),z.x*dz[2].yzw+dz[2].x*z.yzw);
        //dz[3]=vec4(dot(mz,dz[3]),z.x*dz[3].yzw+dz[3].x*z.yzw);

        // z = z2 + c
        nz.x=dot(z, mz);
        nz.yzw=2.0*z.x*z.yzw;
        z=nz+c;

        if(dot(z,z)>4.0)
            break;
        }

    normal = vec3(dot(z,dz[0]),dot(z,dz[1]),dot(z,dz[2]));
    return normal;
}

float jinteresct(in vec3 rO, in vec3 rD, out float ao, out vec3 normal)
{
    float mz2,md2,dist,t;
    float res=1000.0;
    vec4 z;
    vec4 dz;

    vec4 c = cccc;

    ao = 0.0;

    for(t=0.0;t<50.0;t+=dist)
    {
        ao += 1.0;
        vec3 p=rO+t*rD;

	p = rotate(p, transform);
#if 0
	p.xy = mod(p.xy + 2.0, 4.0) - 2.0;
        //p.z = mod(p.z + 30.0, 60.0) - 30.0;
#endif

#if 0
	// torus
	dist = length(vec2(length(p.xy) - 1.0, p.z)) - 0.4;

        #define COMPUTE_NORMAL { \
	vec2 q = p.xy; \
	q *= 1.0 / length(q); \
	normal = p - vec3(q,0.0); }
#elif 0
	// pipe
	dist = 0.0;
	dist = max(dist, length(p.xy) - 1.0);
	dist = max(dist, -length(p.xy - 0.1) + 0.6);
	dist = max(dist, -1.0-p.z);
	dist = max(dist, -1.0+p.z);

        #define COMPUTE_NORMAL { \
	    if (abs(length(p.xy) - 1.0) < 0.001) \
		normal = vec3(p.xy,0.0); \
	    else if (abs(-length(p.xy - 0.1) + 0.6) < 0.001) \
		normal = -vec3(p.xy-0.1,0.0); \
	    else if (abs(-1.0-p.z) < 0.001) \
		normal = vec3(0.0, 0.0, -1.0); \
	    else if (abs(-1.0+p.z) < 0.001) \
		normal = vec3(0.0, 0.0, 1.0); \
	}
#elif 1
	// supersphere
	float k = 10.0;
	vec3 pk = pow(abs(p), vec3(k));
	dist = pow(pk.x + pk.y + pk.z, 1.0/k) - 0.8;
        #define COMPUTE_NORMAL normal = pk / p
#elif 0
	// Sierpinski tetrahedron
	int n = 3;
	normal = p;
	for (int i = 0; i < n; i++) {
	    if (p.x+p.y < 0.0)
		{p.xy = -p.yx; normal.xy=-normal.yx;}
	    if (p.x+p.z < 0.0)
		{p.xz = -p.zx; normal.xz=-normal.zx;}
	    if (p.y+p.z < 0.0)
		{p.yz = -p.zy; normal.yz=-normal.zy;}
	    p = p*2.0 - (2.0-1.0);
	    normal = 2.0*normal - 1.0;
	    if (dot(p,p) > 1e6)
		break;
	}
	dist = (length(p)-2.0) * pow(2.0, -float(n));
	normal = normal;
#else
        // quaternion julia set
        z=vec4(p,0.0); //(c.y+c.x)*.3);
        md2=1.0;
	//dz = vec4(1.0,0.0,0.0,0.0);
        mz2=dot(z,z);

        for(int i=0;i<max_iter;i++)
        {
             // |dz|^2 -> 4*|dz|^2
             md2*=4.0*mz2;
	     //dz = 2.0 * qmul(dz, z) + vec4(1.0,0.0,0.0,0.0);
             // z -> z2 + c
	     z = qsqr(z) + c;

             mz2=dot(z,z);
             if(mz2>bailout)
                 break;
         }

	 //float md2 = dot(dz,dz);
         dist=0.2*sqrt(mz2/md2)*log(mz2);
	     normal = calcNormal(p);
#endif

         if(dist<0.0001)
         {
	     COMPUTE_NORMAL;
             res=t;
             break;
         }
     }

    normal = rotate(normalize(normal), inverse_transform);
    return res;
}

vec3 trace(vec3 pos, vec3 dir)
{
    vec3 color = vec3(0.0);
    vec3 w = vec3(1.0);

    for (int i = 0; i < 10; i++) {
    float ao;
    vec3 nor;
    float t = jinteresct(pos,dir,ao,nor);
    if(t<1000.0)
    {
        vec3 inter = pos + t*dir*.99;
#if 0
        if (inter.z < -0.5) {
	    //return vec3(0.0,1.0,0.0);
	    inter.z = -1.0;
            //nor = vec3(0.0,0.0,1.0);
	}
#endif

	vec3 light = normalize(vec3(1.0,5.0,-3.0));
        float dif = .5 + .5*dot( nor, light); //vec3(0.57703) );
        ao = max( 1.0-ao*0.005, 0.0 );

#if 0
        color = vec3(1.0,.9,.5)*dif +  .5*vec3(.6,.7,.8);
	color *= ao;
	return color;
#endif

	pos = inter;
	dir = reflect(dir, nor);
	w *= vec3(.9, .88, .85);
    }
    else
    {
	float t2 = (pos.y - 100.0) / dir.y;
	if (t2 > 0.0) {
            vec3 p = pos + t2*dir*.99;
	    p = rotate (p, rotate_xz(-0.2 * time));
            color = vec3(.5 * smoothstep(sin(p.x / 30.0) * sin(p.z / 30.0), 0.0, 1.0) + .5);
	} else {
            //color = vec3(0.5,0.51,0.52)+vec3(0.5,0.47,0.45)*p.y;
            color = vec3(0.5,0.51,0.52)+vec3(0.5,0.47,0.45)*dir.y;
	}
	return w * color;
    }}

    return vec3(1.0,.2,.2);
}

mat4 inverse (mat4 a)
{
  float s0 = a[0][0] * a[1][1] - a[1][0] * a[0][1];
  float s1 = a[0][0] * a[1][2] - a[1][0] * a[0][2];
  float s2 = a[0][0] * a[1][3] - a[1][0] * a[0][3];
  float s3 = a[0][1] * a[1][2] - a[1][1] * a[0][2];
  float s4 = a[0][1] * a[1][3] - a[1][1] * a[0][3];
  float s5 = a[0][2] * a[1][3] - a[1][2] * a[0][3];

  float c5 = a[2][2] * a[3][3] - a[3][2] * a[2][3];
  float c4 = a[2][1] * a[3][3] - a[3][1] * a[2][3];
  float c3 = a[2][1] * a[3][2] - a[3][1] * a[2][2];
  float c2 = a[2][0] * a[3][3] - a[3][0] * a[2][3];
  float c1 = a[2][0] * a[3][2] - a[3][0] * a[2][2];
  float c0 = a[2][0] * a[3][1] - a[3][0] * a[2][1];

    // Should check for 0 determinant
  float invdet = 1.0 / (s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0);

  mat4 b;

  b[0][0] = ( a[1][1] * c5 - a[1][2] * c4 + a[1][3] * c3) * invdet;
  b[0][1] = (-a[0][1] * c5 + a[0][2] * c4 - a[0][3] * c3) * invdet;
  b[0][2] = ( a[3][1] * s5 - a[3][2] * s4 + a[3][3] * s3) * invdet;
  b[0][3] = (-a[2][1] * s5 + a[2][2] * s4 - a[2][3] * s3) * invdet;

  b[1][0] = (-a[1][0] * c5 + a[1][2] * c2 - a[1][3] * c1) * invdet;
  b[1][1] = ( a[0][0] * c5 - a[0][2] * c2 + a[0][3] * c1) * invdet;
  b[1][2] = (-a[3][0] * s5 + a[3][2] * s2 - a[3][3] * s1) * invdet;
  b[1][3] = ( a[2][0] * s5 - a[2][2] * s2 + a[2][3] * s1) * invdet;

  b[2][0] = ( a[1][0] * c4 - a[1][1] * c2 + a[1][3] * c0) * invdet;
  b[2][1] = (-a[0][0] * c4 + a[0][1] * c2 - a[0][3] * c0) * invdet;
  b[2][2] = ( a[3][0] * s4 - a[3][1] * s2 + a[3][3] * s0) * invdet;
  b[2][3] = (-a[2][0] * s4 + a[2][1] * s2 - a[2][3] * s0) * invdet;

  b[3][0] = (-a[1][0] * c3 + a[1][1] * c1 - a[1][2] * c0) * invdet;
  b[3][1] = ( a[0][0] * c3 - a[0][1] * c1 + a[0][2] * c0) * invdet;
  b[3][2] = (-a[3][0] * s3 + a[3][1] * s1 - a[3][2] * s0) * invdet;
  b[3][3] = ( a[2][0] * s3 - a[2][1] * s1 + a[2][2] * s0) * invdet;

  return b;
}

void main(void)
{
    vec2 p = vec2(8.0/5.0,6.0/5.0) * (gl_FragCoord.xy / resolution.xy - .5);
    //cccc = vec4( .7*cos(.5*time), .7*sin(.3*time), .7*cos(1.0*time), .7*cos(2.0*time) );
    cccc = vec4( .7*cos(2.5*time), .7*sin(1.3*time), 0.0, 0.0);
    vec3 edir = normalize(vec3(p,1.0));
    vec3 wori = vec3(0.0,0.0,-3.0);

	//cccc = vec4(-.5, .1, 0.0, 0.0);
	//cccc = vec4(-1.47409435510635, -0.00043243408203125, 0.00043243408203125, 0.0);
	//cccc = vec4(-0.817795, -0.2000035, 0.0, 0.0);
	//cccc = vec4(-0.817795, -0.2000035, -0.2000035, 0.0);
	//cccc = vec4(-0.75, 0.11, 0.0, 0.0);

    transform =
	rotate_xy(2.0*time) * 
	rotate_xz(3.0*time + 1.5*p.y*cos(10.0*time)*sin(time)) *
	rotate_xy(0.5*time);
    inverse_transform = inverse(transform);

    vec3 color = trace(wori, edir);
    gl_FragColor = vec4(color,1.0);
}
