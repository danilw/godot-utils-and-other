shader_type spatial;
render_mode blend_mix,depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec3 dir_angle;
uniform sampler2D iChannel0;
uniform float iTime;


//clouds from https://www.shadertoy.com/view/ll3XRf
//sky texture from https://opengameart.org/content/cloudy-skyboxes

float Hash(vec2 p)
{
	p  = fract(p / vec2(.166,.173));
    p += dot(p.xy, p.yx+19.19);
    return fract(p.x * p.y);
}

float Noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float res = mix(mix( Hash(p), Hash(p+ vec2(1.0, 0.0)),f.x),
                    mix( Hash(p+ vec2(.0, 1.0)), Hash(p+ vec2(1.0, 1.0)),f.x),f.y);
    return res;
}

float FractalNoise(in vec2 xy)
{
	float w = .7;
	float f = 0.0;
	for (int i = 0; i < 3; i++)
	{
		f += Noise(xy) * w;
		w = w*0.6;
		xy = 2.0 * xy;
	}
	return f;
}

vec2 uv_sphere(vec3 v)
{
	float pi = 3.1415926536;
	return vec2(0.5 + atan(v.z, v.x) / (2.0 * pi), acos(v.y) / pi);
}

vec3 sky(in vec3 rd)
{
	vec3 sunLight  = normalize( -dir_angle);
	vec3 sunColour = vec3(1.0, .58, .39);
	vec3 cloud_col = vec3(1.,0.95,1.);
	float sunAmount = max( dot( rd, sunLight), 0.0 );
	float v = pow(1.0-max(rd.y,0.0),6.);
	
	vec3 skyc=texture(iChannel0,uv_sphere(rd)).rgb;
	skyc = sqrt(skyc)*0.3;
	vec3  sky = mix(skyc, vec3(.32, .32, .32), v);
	
	/* sun rays */
	sky = sky + sunColour * sunAmount * sunAmount * .25;
	

	sky = sky + sunColour * min(pow(sunAmount, 800.0)*1.5, .4);

	/* clouds */
	vec2 iuv = rd.xz * (1.0/rd.y);
    iuv+=rd.y>0.?iTime:-iTime;
	v = FractalNoise(iuv) * .3;
	sky = mix(sky, sunColour, v*v);

	return clamp(sky+vec3(.2,.2,.2), 0.0, 1.0);
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	rd=-rd;
	vec3 sky_col=sky(rd);
	
	ALBEDO=sky_col;
	
	//ALBEDO=ALBEDO*ALBEDO; //to use in Godot GLES3 add this color correction
	
}
