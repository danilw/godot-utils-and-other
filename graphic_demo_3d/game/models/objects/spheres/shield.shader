shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back,specular_disabled,vertex_lighting,diffuse_lambert;
uniform sampler2D noisetx;
uniform float iTime;

//base on https://www.shadertoy.com/view/ldlXRS

float noise( in vec2 x ){return texture(noisetx, x*.01).x;}

float fbm(in vec2 p)
{	
	float z=2.;
	float rz = 0.;
	vec2 bp = p;
	for (float i= 1.;i < 6.;i++)
	{
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = p*2.;
	}
	return rz;
}

mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(vec2(c,-s),vec2(s,c));}

float dualfbm(in vec2 p, float tv)
{
	vec2 p2 = p*.7;
	float time=tv*0.05;
	vec2 basis = vec2(fbm(p2-time*1.6),fbm(p2+time*1.7));
	basis = (basis-.5)*0.76;
	p += basis;
	return fbm(p*makem2(time*0.72));
}


const vec2 near_far=vec2(0.1,50.0);

float linearize(float val) {
    val = 2.0 * val - 1.0;
    val = 2.0 * near_far[0] * near_far[1] / (near_far[1] + near_far[0] - val * (near_far[1] - near_far[0]));
    return val;
}

const vec3 col_o=vec3(0.79,0.43,1.);

// base on https://github.com/curly-brace/godot_force_shield_shader
void fragment() {
	ALBEDO=vec3(0.);
	if(UV.y>0.35){
		return;
	}
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
    float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).r);
    float zpos = linearize(FRAGCOORD.z);
    float diff = zdepth - zpos;
    float intersect = 0.0;
    if (diff > 0.0) {
        intersect = 1.0 - smoothstep(0.0, (1.0/near_far[1])*10.0, diff);
    }
    
	float timer=iTime*0.1;
	timer=mod(timer,3.)-0.3;
	float l0=(1.-smoothstep(0.,0.0075,abs(UV.y-timer-0.045)));
	float l1=(1.-smoothstep(0.,.015,(UV.y-timer-0.03)));
	float l2=(smoothstep(-0.5,.5,(UV.y-timer+01.15)))*l1;
	l1=(1.-smoothstep(0.,0.0075,(UV.y-timer-0.045)))*(smoothstep(0.,.15,(UV.y-timer+0.03)));
	
	float ext=1.-smoothstep(-0.05,0.28-0.25*smoothstep(1.,2.4,timer),UV.y);
	
    float oglow = clamp(intersect+ext*0.6,0.,1.);
	float glow=0.;
	
	float rz = dualfbm(nor.xz*(5.+22.*(smoothstep(0.,0.7,UV.y))),iTime);
	rz=max(rz,0.001);
	float tglow=1./rz;
	glow=tglow*(max(max(l1*0.5,l0*0.75),l2*0.035));
	float rglow=tglow*(max(max(l1*0.5,l0*0.5),l2*0.25));
	glow+=oglow*(tglow*.15*max((1.-smoothstep(1.75,2.75,timer))*smoothstep(0.3,0.4,timer),rglow)+rglow*2.5);
	glow=clamp(glow,0.,6.);
	
	EMISSION = pow(glow*col_o, vec3(2.))*1.;
	vec3 ref_normal = NORMAL;
	rglow=clamp(rglow/10.,0.,1.);
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * rglow;
	EMISSION += texture(SCREEN_TEXTURE,ref_ofs).rgb ;
}