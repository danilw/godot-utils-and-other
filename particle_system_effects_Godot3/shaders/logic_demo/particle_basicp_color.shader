shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,unshaded;

uniform float iTime;
uniform sampler2D test_texture:hint_albedo;

// this logic based on my own old demo https://youtu.be/405yudjksDA

float get_xt(float xpi,float px){
	return xpi*px;
}

float get_x(float xpi,float px){
	const float pi=3.1415926;
	return -pi*xpi + xpi*2.*pi*px;
}

//return [x,y]-positions [z,w] color fix
vec4 get_func(int fid,float x){
	const float pi=3.1415926;
	float ret=0.;
	float rety=((x-0.5)*4.)*(1./0.2);
	float cpw=0.15;
	float t=0.;
	const float maxh=15.;
	switch (fid) {
        case 0:t=get_x(1.,x);ret=tan(t);break;
		case 1:t=get_x(1.,x);ret=t * t * t;break;
		case 2:t=get_x(2.,x);ret=(6. * sin(t)) / 2.;break;
		case 3:t=get_x(1.,x);ret=1. / tan(t);break;
		case 4:t=get_x(2.,x);ret=abs(t) * sin(t);break;
		case 5:t=get_x(2.,x);ret=t / (t * t);break;
		case 6:t=get_x(2.,x);ret=-t * sin(t);break;
		case 7:cpw=0.05;t=get_xt(1.,rety);rety=2.5*(2.*cos(t) + cos(2.*t));ret=2.5*(2. * sin(t) - sin(2.*t));break;
		case 8:cpw=0.05;t=get_xt(1.,rety);rety=1.5*(4.* (cos(t) + cos(5.* t)/ 5.));ret=1.5*(4.* (sin(t) - sin(5.* t)/ 5.));break;
		case 9:cpw=0.05;t=get_xt(10.,rety);rety=1.5*(2.8 * (cos(t) + cos(1.1 * t) / 1.1));ret=1.5*(2.8 * (sin(t) - sin(1.1 * t) / 1.1));break;
		case 10:cpw=0.075;t=get_xt(1.,rety);rety=1.5*(3.* (1.+ cos(t)) * cos(t));ret=1.5*(3.* (1.+ cos(t)) * sin(t));break;
		case 11:cpw=0.05;t=get_xt(1.,rety);rety=2.5*(3.* sin(t + pi / 2.));ret=2.5*(3.* sin(2.* t));break;
		case 12:cpw=0.05;t=get_xt(3.,rety);rety=2.5*(sin(t)*(exp(cos(t)) - 2.* cos(4.* t) + pow(sin(t / 12.), 5.)));
			ret=-2.5*(cos(t)*(exp(cos(t)) - 2.* cos(4.* t) + pow(sin(t / 12.), 5.)));break;//Butterfly
		case 13:cpw=0.075;t=get_xt(1.,rety);rety=2.5*((16. * pow(sin(t), 3.)) / 4.);
			ret=2.5*((13.* cos(t) - 5.* cos(2. * t) - 2.* cos(3.* t) - cos(4.* t)) / 4.);break;//heart <3
		case 14:t=get_x(1.,x);rety=1.5*(5.* sin(t));ret=1.5*(5. * cos(t));break;
		case 15:cpw=0.075;t=get_x(1.,x);rety=1.5*((cos(t) + pow(cos(8. * t), 3.))*3.);ret=1.5*((sin(8.* t) + pow(sin(t), 4.))*2.5);break;
		case 16:t=get_x(1.,x);rety=2.5*(cos(t) * sqrt((2.* 2.* pow(sin(t), 2.) - 5.* 5.* pow(cos(t), 2.)) / (pow(sin(t), 2.) - pow(cos(t), 2.))));
			ret=2.5*(sin(t) * sqrt((2.* 2.* pow(sin(t), 2.) - 5.* 5.* pow(cos(t), 2.)) / (pow(sin(t), 2.) - pow(cos(t), 2.))));break;
		case 17:cpw=0.1;t=get_x(1.,x);rety=2.5*(3.* cos(t)*(1.- 2.* pow(sin(t), 2.)));ret=2.5*(3.* sin(t)*(1.- 2.* pow(cos(t), 2.)));break;
	}
	float cfix=1.;
	if(isinf(ret)){
		ret=maxh;
		cfix=0.;
	}else
	{
		if(isnan(ret)){
			ret=0.;
			cfix=0.;
		}else
		{
			if(abs(ret)>maxh){
				ret=maxh*sign(ret);
				cfix=0.;
			}
		}
	}
	if(isinf(rety)){
		rety=maxh;
		cfix=0.;
	}else
	{
		if(isnan(rety)){
			rety=0.001;
			cfix=0.;
		}else
		{
			if(abs(rety)>maxh){
				rety=maxh*sign(rety);
				cfix=0.;
			}else{
				if(rety==0.)rety=0.001;
			}
		}
	}
	
	return vec4(ret,rety,cfix,cpw);
}

void vertex() {
	int fid=int(iTime/(27.05+.05))%18;
	vec4 val=get_func(fid,0.5-VERTEX.z*0.5);
	VERTEX.y+=-val.x*0.2;
	VERTEX.z=val.y*0.2;
	COLOR.rgb+=0.05*(dot(COLOR.rgb,vec3(1.)));
	COLOR.rgb*=val.z*val.w;
}

// https://iquilezles.org/www/articles/filterableprocedurals/filterableprocedurals.htm
float filteredGrid( in vec2 p, in vec2 dpdx, in vec2 dpdy )
{
    const float N = 10.0;
    vec2 w = max(abs(dpdx), abs(dpdy));
    vec2 a = p + 0.5*w;                        
    vec2 b = p - 0.5*w;           
    vec2 i = (floor(a)+min(fract(a)*N,1.0)-
              floor(b)-min(fract(b)*N,1.0))/(N*w);
    return (i.x);
}

void fragment() {
	vec2 tuv=UV;
	float scale=.75;
	tuv+=-0.5;
	tuv*=scale;
	tuv.x+=(0.5/10.);
	float d=0.;
	//d=filteredGrid(tuv,dFdx(tuv),dFdy(tuv)); //procedural filtered
	//d=1.-step(0.05,abs(tuv.x)); //procedural, not filtered
	
	tuv=UV;
	tuv.x=(tuv.x-0.5)*scale+0.5;
	d=texture(test_texture,tuv).a; //texture
	
	ALBEDO=vec3(0.);
	float fade_distance=-VERTEX.z;
	float fade=clamp(smoothstep(0.,.51,fade_distance),0.0,1.0);
	ALBEDO=d*COLOR.rgb;
	ALBEDO*=fade;
	
	//ALBEDO=vec3(1.);
}
