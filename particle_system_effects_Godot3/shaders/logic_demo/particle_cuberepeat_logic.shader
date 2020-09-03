shader_type particles;
render_mode keep_data,disable_velocity,disable_force;

uniform int line_size;
uniform float iTime;

mat4 rotationAxisAngle( vec3 v, float angle )
{
    float s = sin( angle );
    float c = cos( angle );
    float ic = 1.0 - c;

    return mat4( vec4(v.x*v.x*ic + c,     v.y*v.x*ic - s*v.z, v.z*v.x*ic + s*v.y, 0.0),
                 vec4(v.x*v.y*ic + s*v.z, v.y*v.y*ic + c,     v.z*v.y*ic - s*v.x, 0.0),
                 vec4(v.x*v.z*ic - s*v.y, v.y*v.z*ic + s*v.x, v.z*v.z*ic + c,     0.0),
                 vec4(0.0,                0.0,                0.0,                1.0) );
}

const float cube_size=0.15;
const float size_mod=0.1;

vec3 build_cube(int idx){
	float cz=cube_size*(1./(1.+size_mod*float(idx/12)));
	vec3 ret=vec3(cz-2.*cz*float((idx%4)/2),cz-2.*cz*float((idx%2)),0.);
	switch((idx%12)/4){
		case 0:ret=ret.xyz;break;
		case 1:ret=ret.xzy;break;
		case 2:ret=ret.zyx;break;
	}
	return ret;
}

void vertex() {

    float pi = 3.1415926;
    float degree_to_rad = pi / 180.0;
    CUSTOM=vec4(vec3(0),110.);
    TRANSFORM = EMISSION_TRANSFORM;
	
	
    int idx=INDEX;
	float cz=cube_size*(1./(1.+size_mod*float(idx/12)));
    TRANSFORM[3].xyz=build_cube(idx);
	
	float an = cos(iTime*0.43+float(idx/12)*pi*0.01)*pi;
	float ab=sin(iTime*0.23+float(idx/12)*pi*0.01);
	mat4 rm=rotationAxisAngle(normalize(vec3(ab,1.,0.)),an);
	vec3 ps=(rm*vec4(build_cube(idx),0.)).xyz;
	TRANSFORM[3].xyz=ps;
	TRANSFORM*=rm;
	vec3 v=vec3(float((idx%12)/4==1),float((idx%12)/4==2),float((idx%12)/4==3));
	if(length(v)>0.)TRANSFORM*=rotationAxisAngle(v,pi/2.);
	
    TRANSFORM[0].xyz *= 1.;
    TRANSFORM[1].xyz *= 1.;
    TRANSFORM[2].xyz *= cz;
}

