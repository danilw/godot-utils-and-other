shader_type particles;
render_mode keep_data,disable_velocity;

uniform float iTime;

vec3 mlpos(float index, inout float angx, inout float angy){
	float px=index/31.;
	float pi=3.1415926;
	angx=pi/2.+atan(2.*sin(2.*px*pi),2.*cos(2.*px*pi));
	angx=mod(angx,2.*pi);
	float time=mod(10.*iTime,31.);
	float tt=smoothstep(index-8.,index,time);
	tt+=smoothstep(index+31.-8.,index+31.,time);
	time=mod(10.*iTime+4.,31.);
	float tt2=smoothstep(index-8.,index,time)*smoothstep(index+8.,index,time);
	tt2+=smoothstep(index+31.-8.,index+31.,time)+smoothstep(index+8.,index,time)*smoothstep(index-31.+8.,index-31.,time);
	angy=pi*tt;
	angy=-pi/2.+mod(angy,2.*pi);
	return .5*vec3(2.*sin(2.*px*pi),0.*tt2,2.*cos(2.*px*pi));
}

void vertex() {
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;
	
	//if(RESTART)
	if (CUSTOM.w<100.) {
		CUSTOM=vec4(vec3(0),110.);
		VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
		//TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
		TRANSFORM = EMISSION_TRANSFORM;
		TRANSFORM[3].xyz=mlpos(float(INDEX),CUSTOM.x,CUSTOM.y);
		TRANSFORM[0].xyz *= 1.;
		TRANSFORM[1].xyz *= 1.;
		TRANSFORM[2].xyz *= 1.;
		TRANSFORM = TRANSFORM * mat4(vec4(cos(CUSTOM.x), 0.0, -sin(CUSTOM.x), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(sin(CUSTOM.x), 0.0, cos(CUSTOM.x), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		TRANSFORM = TRANSFORM * mat4(vec4(cos(CUSTOM.y), 0.0, -sin(CUSTOM.y), 0.0).zxyw,
		 vec4(0.0, 1.0, 0.0, 0.0).zxyw,
		 vec4(sin(CUSTOM.y), 0.0, cos(CUSTOM.y), 0.0).zxyw,
		 vec4(0.0, 0.0, 0.0, 1.0).zxyw
		);
	} else {
		TRANSFORM = EMISSION_TRANSFORM;
		TRANSFORM[3].xyz=mlpos(float(INDEX),CUSTOM.x,CUSTOM.y);
		TRANSFORM = TRANSFORM * mat4(vec4(cos(CUSTOM.x), 0.0, -sin(CUSTOM.x), 0.0),
		 vec4(0.0, 1.0, 0.0, 0.0),
		 vec4(sin(CUSTOM.x), 0.0, cos(CUSTOM.x),
		 0.0), vec4(0.0, 0.0, 0.0, 1.0)
		);

		TRANSFORM = TRANSFORM * mat4(vec4(cos(CUSTOM.y), 0.0, -sin(CUSTOM.y), 0.0).zxyw,
		 vec4(0.0, 1.0, 0.0, 0.0).zxyw,
		 vec4(sin(CUSTOM.y), 0.0, cos(CUSTOM.y), 0.0).zxyw,
		 vec4(0.0, 0.0, 0.0, 1.0).zxyw
		);
	}
	
	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
}

