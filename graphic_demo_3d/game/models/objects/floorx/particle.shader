shader_type particles;
render_mode keep_data,disable_velocity;
uniform int line_size=15;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

// https://www.shadertoy.com/view/ll2GD3 
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

mat4 rotationAxisAngle( vec3 v, float angle )
{
    float s = sin( angle );
    float c = cos( angle );
    float ic = 1.0 - c;

    return mat4( vec4(v.x*v.x*ic + c,     v.y*v.x*ic - s*v.z, v.z*v.x*ic + s*v.y, 0.0),
                 vec4(v.x*v.y*ic + s*v.z, v.y*v.y*ic + c,     v.z*v.y*ic - s*v.x, 0.0),
                 vec4(v.x*v.z*ic - s*v.y, v.y*v.z*ic + s*v.x, v.z*v.z*ic + c,     0.0),
                 vec4(0.0,                0.0,                0.0,                1.0 ));
}

const float scale=2.0625; //2.0625*2 size of tile, everything calculated base on it (all positions in Editor)

void vertex() {
	if((CUSTOM.w<100.)) 
	{
		uint alt_seed = hash(uint(1+INDEX) + RANDOM_SEED);
		float pi = 3.14159;
		float degree_to_rad = pi / 180.0;
		CUSTOM=vec4(vec3(0),110.);
		TRANSFORM = EMISSION_TRANSFORM;
		vec2 pos=vec2(0.);
		pos=vec2(float(INDEX%line_size),float(INDEX/line_size));
		
		TRANSFORM[3].xyz=vec3(pos.x*2.*scale,0.,pos.y*2.*scale);
		TRANSFORM[0].xyz *= scale;
		TRANSFORM[1].xyz *= scale;
		TRANSFORM[2].xyz *= scale;
		TRANSFORM = TRANSFORM * rotationAxisAngle(vec3(0.,1.,0.),-pi*0.5);
		
		/*
		pos+=rand_from_seed(alt_seed)*float(line_size)*3.;
		pos*=1.;
		vec3 tc=pal((floor((pos.y-0.5)*4.)+floor((pos.y-0.5)*4.)*floor((pos.y-0.5)*4.))*0.1,
		vec3(0.5,0.5,0.5),vec3(0.5,0.2,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.3,0.4) )*10.;
		*/
		
		const float px=6.;
		vec3 tc=vec3(1.1,0.5,0.2)*px;
		if((INDEX/line_size)%2==1)
		tc=vec3(0.2,0.5,01.1)*px;
		
		CUSTOM.rgb=tc;

	//}else{
		
	}
}
