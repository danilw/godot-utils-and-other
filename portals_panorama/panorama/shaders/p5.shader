shader_type spatial;
render_mode blend_mix,depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec3 angle;
uniform sampler2D iChannel0;
uniform float iTime;

//credit //https://www.shadertoy.com/view/4sd3zf
//moon https://opengameart.org/content/moon


mat3 rotx(float a) { mat3 rot; rot[0] = vec3(1.0, 0.0, 0.0); rot[1] = vec3(0.0, cos(a), -sin(a)); rot[2] = vec3(0.0, sin(a), cos(a)); return rot; }
mat3 roty(float a) { mat3 rot; rot[0] = vec3(cos(a), 0.0, sin(a)); rot[1] = vec3(0.0, 1.0, 0.0); rot[2] = vec3(-sin(a), 0.0, cos(a)); return rot; }
mat3 rotz(float a) { mat3 rot; rot[0] = vec3(cos(a), -sin(a), 0.0); rot[1] = vec3(sin(a), cos(a), 0.0); rot[2] = vec3(0.0, 0.0, 1.0); return rot; }


vec2 uv_sphere(vec3 v)
{
	float pi = 3.1415926536;
	return vec2(0.5 + atan(v.z, v.x) / (2.0 * pi), acos(v.y) / pi);
}

float hash(float n) { return fract(sin(n)*753.5453123); }

float noise(vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z)-0.4;
}

float clouds(vec3 p) {
	vec3 q = p+vec3(-0.1,0.37,1.0)*2.0*iTime+vec3(0.0, sin(p.y)*100.0, 0.0);
	float v = 0.0;
	v += 0.550 * noise(q*0.051);
	v += 0.250 * noise(q*0.111);
	v += 0.125 * noise(q*0.211);
    
	return v;
}


vec3 sky(vec3 rd, vec2 scr_uv)
{
	vec3 ord=rd;
    vec2 PX_RES=vec2(320.0,200.0);
    rd=floor(rd*PX_RES.y)/PX_RES.y;
    scr_uv=floor(scr_uv*PX_RES)/PX_RES;
	vec3 col;

    float t = (20.0 ) / rd.y;		

    float colv = 0.0;
	if (rd.y>0.) {				
		// clouds
		float cloudA = 1.0;
        cloudA *= pow(smoothstep(0.0, 1.0, 90.0/t), 1.5);	// lower dim
        cloudA *= pow((smoothstep(0.0, 1.0, t/35.0)), 1.5); //upper dim
		colv += cloudA * smoothstep(0.0, 0.8, 0.2+clouds(t *1.3* rd));				
	}		
	
    colv*=1.5;
    colv *= min(1.0, colv);
    
    const float step1 = 1.0/4.;
    float testvar = mod(colv, step1);
    
    bool xgrid = mod(scr_uv.x*PX_RES.x, 2.0)<1.0;
    bool ygrid = mod(scr_uv.y*PX_RES.y, 2.0)<1.0;

	
    // dither
    colv += testvar>step1*0.20 &&  xgrid &&  ygrid ? step1:0.0;
    colv += testvar>step1*0.40 && !xgrid && !ygrid ? step1:0.0;
    colv += testvar>step1*0.60 &&  xgrid && !ygrid ? step1:0.0;
    colv += testvar>step1*0.80 && !xgrid &&  ygrid ? step1:0.0;
    
	//draw moon texture on position
	ord=rd;
	vec3 ta=angle.zyx;
	ta.y+=1.571;
	ord*=rotx(ta.x);
	ord*=roty(ta.y);
	ord*=rotz(ta.z);
	vec2 tuv=uv_sphere(ord);
	tuv=(tuv-0.5)*15.+0.5;
	tuv.x*=2.;
	if((abs(tuv.x-0.5)<.5)&&(abs(tuv.y-0.5)<.5)){
		vec4 tx=texture(iChannel0,tuv);
	    colv=mix(colv,colv*(1.-tx.a)+tx.r*tx.a*1.3,clamp(colv,0.,1.))+tx.r*tx.a*0.25;
	}
    
    col=vec3(colv);
    col *= vec3(0.8, 0.9, 1.84);
    col += vec3(0.1, 0.15, 0.3); 

    if(rd.y<0.)rd.y*=0.52;
    float hor=1.-max(abs(rd.y),0.);
	float hor_power=pow(hor,106.0); //horizont, remove if not needed
    if(rd.y<0.)
    col=mix(col+col*hor_power,vec3(col)*0.5+col*hor_power,1.-hor_power);
    else col+=col*hor_power;
    
	return clamp(col,0.,1.);
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	rd=-rd;
	vec3 sky_col=sky(rd,SCREEN_UV);
	ALBEDO=sky_col;
	//ALBEDO=ALBEDO*ALBEDO; //to use in Godot GLES3 add this color correction
	
}
