shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform vec4 blendx;

const float power=1.25;

void vertex() {
	
}

// https://iquilezles.org/www/articles/filterableprocedurals/filterableprocedurals.htm
float filteredGrid( in vec2 p, in vec2 dpdx, in vec2 dpdy )
{
    const float N = 100.0;
    vec2 w = max(abs(dpdx), abs(dpdy));
    vec2 a = p + 0.5*w;                        
    vec2 b = p - 0.5*w;           
    vec2 i = (floor(a)+min(fract(a)*N,1.0)-
              floor(b)-min(fract(b)*N,1.0))/(N*w);
    return (1.0-i.x)*(1.0-i.y);
}


const vec3 co=vec3(1.);
const vec3 cr=vec3(1.,0.53,0.16);
const vec3 cg=vec3(0.23,0.94,0.57);
const vec3 cb=vec3(0.32,0.65,1.);


void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
	vec2 tuv = UV;
	METALLIC = 0.0;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	
	vec3 col=vec3(0);
	vec3 cx1=vec3(0.);
	vec3 cx2=vec3(0.);
	vec3 cx3=vec3(0.);
	vec3 cx4=vec3(0.);
	vec3 cx=vec3(0.);
	
	if(blendx.x>0.){cx1=co*power;}
	if(blendx.y>0.){cx2=cb*power;}
	if(blendx.z>0.){cx3=cg*power;}
	if(blendx.w>0.){cx4=cr*power;}
	cx=cx2*blendx.y+cx3*blendx.z+cx4*blendx.w+cx1*blendx.x;
	
	float v=0.;
	if((nor.r>0.5))v=.5;
	vec2 p = (tuv-vec2(0.,v+0.001))*vec2(21.,20.1*20.);
	
	float fgr=filteredGrid(p,dFdx(p),dFdy(p));
	if((nor.g>0.5)||(nor.g<-0.5))fgr=1.;
	col=clamp(col,0.,1.);
	col=col+clamp(1.-fgr,0.,1.)*cx;
	ALBEDO=col;
	EMISSION=col;
	
}
