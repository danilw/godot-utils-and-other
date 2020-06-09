shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform sampler2D tx_o : hint_albedo;
uniform sampler2D tx_b : hint_albedo;
uniform sampler2D tx_g : hint_albedo;
uniform sampler2D tx_r : hint_albedo;
uniform sampler2D tx_og : hint_albedo;
uniform sampler2D tx_fg : hint_albedo;
uniform vec4 blendx;

const float power=1.25;

void vertex() {
	
}

float floor_grid(vec2 p) {
    vec2 e = min(vec2(1.0), fwidth(p)); 
	vec2 a = 1.-smoothstep(1.0 - e, vec2(1.001), fract(p));
	vec2 b = smoothstep(vec2(0.0), e + 0.001, fract(p));
    vec2 l = (1.-(clamp((a + b),0.,2.) - (1.0 - e)))*clamp(1.0 - 8.*e,0.,1.);
    return clamp(((l.x + l.y) ),0.,1.);
}

// https://www.shadertoy.com/view/ll2GD3 
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

float lines_fg(vec2 uv, float t, float baa){
	uv = uv*50.;
    float freq = smoothstep(-1.,1.,-cos(t*0.5))*0.25+0.075;
    uv.x += sin((floor(uv.y*.5+.5)*2.-1.)*freq + t*2.5)*14.;
    float phase = floor(uv.y*.5+.5)*2.-1.;
    float size = smoothstep(-1.,1.,sin(t*3. +phase*.125))*10.;
    uv.y = fract(uv.y*.5+.5)*2.-1.;
	return smoothstep(0.4-baa,0.6+baa,length(uv - vec2(clamp(uv.x,-size, size), 0)));
}

const vec3 co=vec3(1.);
const vec3 cr=vec3(1.,0.53,0.16);
const vec3 cg=vec3(0.23,0.94,0.57);
const vec3 cb=vec3(0.32,0.65,1.);

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
	float baa=(length((((vec4(VERTEX,0.))).xyz))-1.)/11.;
	baa=clamp(baa,0.,1.);
	baa*=13.;
	
	vec2 tuv = UV;
	METALLIC = 0.0;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	
	vec3 col=vec3(0);
	vec3 c1=vec3(0);
	vec3 c2=vec3(0);
	vec3 c3=vec3(0);
	vec3 c4=vec3(0);
	vec3 cx1=vec3(0.);
	vec3 cx2=vec3(0.);
	vec3 cx3=vec3(0.);
	vec3 cx4=vec3(0.);
	vec3 cx=vec3(0.);
	
	if(blendx.x>0.){c1=texture(tx_o,tuv).rgb*power;cx1=co*power;}
	if(blendx.y>0.){c2=texture(tx_b,tuv).rgb*power;cx2=cb*power;}
	if(blendx.z>0.){c3=texture(tx_g,tuv).rgb*power;cx3=cg*power;}
	if(blendx.w>0.){c4=texture(tx_r,tuv).rgb*power;cx4=cr*power;}
	col=c2*blendx.y+c3*blendx.z+c4*blendx.w;
	cx=cx2*blendx.y+cx3*blendx.z+cx4*blendx.w+cx1*blendx.x;
	//col=clamp(col,0.,1.);
	col=c1*blendx.x+col;
	
	//float dx=max(dot(NORMAL, normalize(VIEW)),0.);
	//vec2 p = (rd).xy;
	//vec2 p = (rd*dx).xy;
	//vec2 p = tuv*dx;
	vec2 p = tuv;
	
	vec3 cog=texture(tx_og,tuv).rgb;
	
	float fgr=floor_grid(p*20.0);
	ivec2 idx=ivec2(p*20.);
	float t=texelFetch(tx_fg,idx,0).r;
	float tv=clamp(texelFetch(tx_fg,idx,0).b,0.,1.);
	float tc=clamp(texelFetch(tx_fg,idx,0).a,0.,1.);
	vec3 tcx=vec3(0.);
	if(tv>0.01){
		p=(fract(p*20.)-0.5);
		float pv=(float(idx.x+20*idx.y)/400.)*3.1415926*8.;
		float fgx = 1.-min(lines_fg(p*-1.,t+pv,baa),lines_fg(p.yx,t+pv,baa));
		fgx*=clamp(1.-baa/8.,0.,1.);
		tcx=fgx*pow(pal((floor((tuv.x-0.5)*20.)+floor((tuv.x-0.5)*20.)*floor((tuv.y-0.5)*20.))*0.1,
		vec3(0.5,0.5,0.5),vec3(0.5,0.2,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.3,0.4) )*2.,vec3(.5+1.5*tc*tv))*(0.1+.65*tc*tv)*tv;
	}
	col=clamp(col,0.,1.);
	col=col+clamp(fgr-20.*fgr*dot(col,vec3(1.)),0.,1.)*0.15*cx;
	col*=clamp((1.5*pow(cog.r,1.)),0.,1.);
	float a=clamp(dot(col,vec3(1.))*20.,0.,1.);
	col+=tcx*(1.-a);
	ALBEDO=col;
	EMISSION=col;
	//ALPHA=a;
	
}
