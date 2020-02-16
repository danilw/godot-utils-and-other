shader_type spatial;
render_mode blend_mix,depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec3 dir_angle;
uniform sampler2D iChannel0;
uniform float iTime;

//sky panorama from https://opengameart.org/content/ulukais-space-skyboxes

float hash(in vec3 p)
{
  return fract(sin(dot(p,
    vec3(12.6547, 765.3648, 78.653)))*43749.535);
}

float noise3(in vec3 p)
{
  vec3 pi = floor(p);
  vec3 pf = fract(p);

  pf = pf*pf*(3.-2.*pf);

  float a = hash(pi + vec3(0., 0., 0.));
  float b = hash(pi + vec3(1., 0., 0.));
  float c = hash(pi + vec3(0., 1., 0.));
  float d = hash(pi + vec3(1., 1., 0.));

  float e = hash(pi + vec3(0., 0., 1.));
  float f = hash(pi + vec3(1., 0., 1.));
  float g = hash(pi + vec3(0., 1., 1.));
  float h = hash(pi + vec3(1., 1., 1.));

  return mix(mix(mix(a,b,pf.x),mix(c,d,pf.x),pf.y),
  mix(mix(e,f,pf.x),mix(g,h,pf.x),pf.y), pf.z);
}

float fbm3(vec3 rd) {
  float f = .5*noise3(rd);
  vec3 off = vec3(0.01, 0.01, 0.01);
  f += .25*noise3(rd*2.02 + off);
  f += .125*noise3(rd*4.01 + off);
  f += .065*noise3(rd*8.03 + off);
  f += .0325*noise3(rd*16.012 + off);

  return f;
}

vec2 uv_sphere(vec3 v)
{
	float pi = 3.1415926536;
	return vec2(0.5 + atan(v.z, v.x) / (2.0 * pi), acos(v.y) / pi);
}

vec3 sky(in vec3 rd)
{
	vec3 tcol=vec3(0.);
	tcol=texture(iChannel0,uv_sphere(rd)).rgb;
    vec3 col=vec3(0.);
    vec3 sunLight  = -normalize(dir_angle);
    vec3 sunColour = vec3(1.0, .58, .39)*3.;
    float sunAmount = max( dot( rd, sunLight), 0.0 );

    vec3 sun = sunColour * min(pow(sunAmount, 800.0)*1.5, .4);

    rd*=4.;
    float f = fbm3(rd);
    float tt = 0.1*iTime;
    float f2 = fbm3(rd+2.*vec3(cos(f) + cos(tt), sin(f)+sin(tt),cos(f) + cos(tt)) );
    vec3 sky = vec3(.1,0.1,0.9);
    
    //noise colors generated base on next lines and col.r/g/b after
    vec3 col1 = mix(vec3(1.,1.,0.), vec3(1.,0.,1.), f);
    vec3 col2 = mix(sky, vec3(1.,1.,1.),f2);
    col += mix(col2, col1, f*f2);
    
    col = mix(tcol, col, 2.*(  col.r*col.g));
    col += sun*(4.*(1.-col.g)*exp(-col.g*4.));
    col = mix(col, sun, clamp(4.*(1.-col.g-col.r)*exp((-col.g-col.r)*4.), 0.,1.));
    col=clamp(col*col,0.,1.);
    col=(tcol+tcol*tcol+col-tcol*col*0.5);
    return clamp(col,0.,1.);
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	rd=-rd;
	vec3 sky_col=sky(rd);
	ALBEDO=sky_col;
	//ALBEDO=ALBEDO*ALBEDO; //to use in Godot GLES3 add this color correction
	
}
