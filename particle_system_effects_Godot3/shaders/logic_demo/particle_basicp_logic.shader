shader_type particles;
render_mode keep_data,disable_velocity,disable_force;

uniform float iTime;


// this logic based on my own old demo https://youtu.be/405yudjksDA

float linearstep(float begin, float end, float t) {
	return smoothstep(begin,end,t);
    //return clamp((t - begin) / (end - begin), 0.0, 1.0);
}

vec3 findaxis(){
	vec3 rotate=vec3(0.);
	
	// copy paste timers and rotation
	//const float timers[12]={140.,282.,423.,565.,706.,847.,988.,1129.,1270.,1411.,1552.,1623.}; //frames
	const float static_timers[12]=float[](2.33333,4.7,7.05,9.41666,11.76666,14.11666,16.4666,18.8166,21.16666,23.51666,25.866,27.05);
	
	float time=mod(iTime,static_timers[11]+.05);
	
	rotate.x=linearstep(static_timers[0],static_timers[1],time)*
	(1.-linearstep(static_timers[1],static_timers[2],time));
	rotate.x+=-linearstep(static_timers[2],static_timers[3],time)*
	(1.-linearstep(static_timers[5],static_timers[6],time));
	rotate.x+=linearstep(static_timers[6],static_timers[7],time)*
	(1.-linearstep(static_timers[9],static_timers[10],time));
	
	rotate.y=linearstep(0.,static_timers[0],time)*
	(1.-linearstep(static_timers[0],static_timers[1],time));
	rotate.y+=-linearstep(static_timers[2],static_timers[3],time)*
	(1.-linearstep(static_timers[3],static_timers[4],time));
	rotate.y+=linearstep(static_timers[4],static_timers[5],time)*
	(1.-linearstep(static_timers[5],static_timers[6],time));
	rotate.y+=-linearstep(static_timers[6],static_timers[7],time)*
	(1.-linearstep(static_timers[7],static_timers[8],time));
	rotate.y+=linearstep(static_timers[8],static_timers[9],time)*
	(1.-linearstep(static_timers[9],static_timers[10],time));
	
	rotate.z=linearstep(static_timers[1],static_timers[2],time)*
	(1.-linearstep(static_timers[2],static_timers[3],time));
	rotate.z+=-linearstep(static_timers[3],static_timers[4],time)*
	(1.-linearstep(static_timers[4],static_timers[5],time));
	rotate.z+=linearstep(static_timers[5],static_timers[6],time)*
	(1.-linearstep(static_timers[6],static_timers[7],time));
	rotate.z+=-linearstep(static_timers[7],static_timers[8],time)*
	(1.-linearstep(static_timers[8],static_timers[9],time));
	rotate.z+=linearstep(static_timers[9],static_timers[10],time)*
	(1.-linearstep(static_timers[10],static_timers[11],time));
	
	return rotate;
}

vec3 get_color(vec3 rotate){
	return abs(rotate*7.) / 14.0;
}

vec3 my_normalize(vec3 v){
	float len = length(v);
	if(len==0.0)return vec3(0.,1.,0.);
	return v/len;
}

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

vec3 encodeSRGB(vec3 linearRGB)
{
    vec3 a = 12.92 * linearRGB;
    vec3 b = 1.055 * pow(linearRGB, vec3(1.0 / 2.4)) - 0.055;
    vec3 c = step(vec3(0.0031308), linearRGB);
    return mix(a, b, c);
}

void vertex() {
    const float pi = 3.1415926;
    CUSTOM=vec4(vec3(0),110.);
    TRANSFORM = EMISSION_TRANSFORM;
    TRANSFORM[3].xyz=vec3(0.);
    TRANSFORM[0].xyz *= 2.;
    TRANSFORM[1].xyz *= 2.;
    TRANSFORM[2].xyz *= 2.;
	
	float idx=float(INDEX);
	
	vec3 rotate=findaxis();
	COLOR=vec4(get_color(rotate),1.);
	//COLOR.b=max(COLOR.g*0.25,COLOR.b);
	COLOR.rgb=sqrt(encodeSRGB(COLOR.rgb));
	rotate=my_normalize(rotate);
	
	TRANSFORM*=rotationAxisAngle(rotate.zyx,((2.*pi)/360.)*idx);
	
}

