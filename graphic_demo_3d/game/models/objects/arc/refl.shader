shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D p_o : hint_albedo;
uniform sampler2D p_b : hint_albedo;
uniform sampler2D p_g : hint_albedo;
uniform sampler2D p_r : hint_albedo;
uniform vec4 blendx;
uniform vec4 emission : hint_color;
uniform float emission_energy;
uniform float iTime;


void vertex() {
	
}

vec2 uv_sphere(vec3 v)
{
	float pi = 3.1415926536;
	vec2 uv=vec2(0.5 + atan(v.z, v.x) / (2.0 * pi), acos(v.y) / pi);
	uv.y=1.-uv.y;
	uv.x=-0.75+uv.x;
	uv=fract(uv);
	return uv;
}

float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }

float noise(vec3 x) {
    const vec3 stepx = vec3(110, 241, 171);

    vec3 i = floor(x);
    vec3 f = fract(x);
 
    float n = dot(i, stepx);

    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix( hash(n + dot(stepx, vec3(0, 0, 0))), hash(n + dot(stepx, vec3(1, 0, 0))), u.x),
                   mix( hash(n + dot(stepx, vec3(0, 1, 0))), hash(n + dot(stepx, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(stepx, vec3(0, 0, 1))), hash(n + dot(stepx, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(stepx, vec3(0, 1, 1))), hash(n + dot(stepx, vec3(1, 1, 1))), u.x), u.y), u.z);
}

float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < 5; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
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

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
	vec2 tuv=uv_sphere(normalize(ref));
	
	vec3 col=vec3(0);
	vec3 c1=vec3(0);
	vec3 c2=vec3(0);
	vec3 c3=vec3(0);
	vec3 c4=vec3(0);
	
	if(blendx.x>0.)c1=pow(texture(p_o,tuv).rgb,vec3(1.25));
	if(blendx.y>0.)c2=pow(texture(p_b,tuv).rgb,vec3(1.25))*0.15;
	if(blendx.z>0.)c3=pow(texture(p_g,tuv).rgb,vec3(1.25));
	if(blendx.w>0.)c4=pow(texture(p_r,tuv).rgb,vec3(1.25));
	
	if (blendx.y>0.01)
	{
		float ts = 0.0;
		vec3 p = ((vec4(nor,0.))*rotationAxisAngle(normalize(vec3(1.,1.,0.5)),mod(iTime*0.25,3.1415926*2.))).rgb*15.;
		for(int i = 0; i < 4; i++)
		{
			p = p * (1. - ts * .25 * float(i + 1));
			ts = fbm((p + 3.0 * float(i)))*0.135;
		}
		ts *= pow(max(dot(NORMAL, normalize(VIEW)),0.), 6.0) * 15.0;
		ts=clamp(ts,0.,5.);
		c2 = vec3(pow(ts,3.), pow(ts,2.), ts)*blendx.y+ts*emission.rgb*0.5;
	}
	
	col=c2*blendx.y+c3*blendx.z+c4*blendx.w;
	//col=clamp(col,0.,1.);
	col=c1*blendx.x+col;
	float itt = smoothstep(0.05,0.25,max(dot(NORMAL, normalize(VIEW)),0.));
	col*=itt;
	
	ALBEDO=vec3(0.);
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	EMISSION=col*6.;
}
