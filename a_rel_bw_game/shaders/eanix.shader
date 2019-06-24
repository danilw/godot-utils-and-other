shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform float iTime;
uniform sampler2D iChannel0;

//my https://www.shadertoy.com/view/4tGcD1
// Created by Danil (2018+)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void vertex() {
}

vec3 saturate(vec3 a){return clamp(a,0.,1.);}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float xRandom(float x){
	return mod(x*7241.6465+2130.465521, 64.984131);
}
float hash2(vec2 co){
    return fract(sin(dot(-1.+co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float hash( vec2 p) { 
    vec2 pos = fract(p / 128.) * 128. + vec2(-64.340622, -72.465622);  
    return fract(dot(vec3(pos.xy,pos.x) * vec3(pos.xy,pos.y), vec3(20.390625, 60.703125, 2.4281209)));  
}
float noise( float y, float t)
{
   	vec2 fl = vec2(floor(y), floor(t));
	vec2 fr = vec2(fract(y), fract(t));
	float a = mix(hash(fl + vec2(0.0,0.0)), hash(fl + vec2(1.0,0.0)),fr.x);
	float b = mix(hash(fl + vec2(0.0,1.0)), hash(fl + vec2(1.0,1.0)),fr.x);
	return mix(a,b,fr.y);
}
float noise2( float y, float t)
{
   	vec2 fl = vec2(floor(y), floor(t));
	vec2 fr = vec2(fract(y), fract(t));
	float a = mix(hash2(fl + vec2(0.0,0.0)), hash2(fl + vec2(1.0,0.0)),fr.x);
	float b = mix(hash2(fl + vec2(0.0,1.0)), hash2(fl + vec2(1.0,1.0)),fr.x);
	return mix(a,b,fr.y);
}
float line(vec2 uv,float width, float center)
{    
    float b		=	(1.- smoothstep(.0, width/2., (uv.y-center)))*1.;//abs
    float b2	=	(1.- smoothstep(.0, 5.*width, (uv.y-center)))*.8;//abs
    return b;//+b2;
}



//const vec3 dark=vec3(0.101,,0.074,0.129);
//const vec3 white=vec3(0.611,0.878,0.819);
//const vec3 red=vec3(0.415,00.211,0.172);
//const vec3 redw=vec3(0.992,0.509,0.466);

float circle( in vec2 uv, float r1, float r2, bool disk)
{
    float w = 2.0*fwidth(uv.x); 
    float t = r1-r2;
    float r = r1;    
    
    if(!disk)
        return smoothstep(-w/2.0, w/2.0, abs(length(uv) - r) - t/2.0);  
    else
        return smoothstep(-w/3.0, w/3.0, (length(uv) - r) );
   
}

mat2 MD(float a){return mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));}
//float animstart=2.5;

vec3 strucb(vec2 uv){
	vec3 red=vec3(0.415,00.211,0.172);
	vec3 redw=vec3(0.992,0.509,0.466);
	vec3 white=vec3(0.611,0.878,0.819);
	vec3 dark=vec3(0.101,0.074,0.129);
	float animstart=6.5;
    float d=step(-0.14,uv.y)*step(uv.y,-0.127)*step(abs(uv.x+0.19),0.02);
    vec3 ret=vec3(0.);
    d=max(d,step(-0.14,uv.y)*(1.-circle(uv+vec2(0.225,0.14),0.02270,0.35,true)));
    d=max(d,step(-0.14,uv.y)*(1.-circle(uv+vec2(0.165,0.14),0.02970,0.35,true)));
    d=max(d,step(uv.y,-0.094)*step(-0.14,uv.y)*smoothstep(0.0031,0.0008,abs(uv.x+0.12)));
    d=max(d,step(uv.y,-0.115)*step(-0.14,uv.y)*smoothstep(0.0031,0.0008,abs(uv.x+0.1075)));
    ret=d*red;
    float tuvx=mod(uv.x,0.006)-0.003;
    d=step(-0.132,uv.y);
    d=step(abs(uv.x+0.225),0.015)*d*smoothstep(0.0031,0.0005,abs(tuvx))*(1.-circle(uv+vec2(0.225,0.143),0.021970,0.35,true));
    ret=mix(ret,redw*1.25,d);
    tuvx=mod(uv.x-0.093,0.012)-0.006;
    d=smoothstep(0.0061,0.0035,abs(tuvx))*step(abs(uv.y+0.122),0.00182);
    ret=mix(ret,white,d*step(abs(uv.x+0.165),0.0165));
    return ret*smoothstep(animstart+2.2,animstart+3.2,iTime); //anim sruct
    
}

vec3 postfx(vec2 uv, vec3 col,float reg){
    vec3 ret=col+ 1.5*reg*((rand(uv)-.5)*.07);
    ret = saturate(1.5*ret);
    return ret;
}

float animendfade(){
	float animstart=6.5;
    return smoothstep(animstart+11.5,animstart+9.5,iTime);
}

float animendfades(){
	float animstart=6.5;
    return step(animstart+9.5,iTime);
}

vec3 map(vec2 uv, float lt){
	vec3 red=vec3(0.415,00.211,0.172);
	vec3 redw=vec3(0.992,0.509,0.466);
	vec3 white=vec3(0.611,0.878,0.819);
	vec3 dark=vec3(0.101,0.074,0.129);
	float animstart=6.5;
	float PI=(4.0 * atan(1.0));
	float TWO_PI=PI*2.;
    float d=(circle(uv,0.32*smoothstep(animstart-1.,animstart+0.35,iTime),0.,true));
    
    vec3 tcol=d*dark;
    float a=1.-circle(uv,0.3542,0.35,false);
    vec2 tuv=uv;
    float af = atan(tuv.x,tuv.y);
    float r = length(tuv)*0.75;
    tuv = vec2(af/TWO_PI,r);
    a*=step(tuv.x,-PI/2.+PI*smoothstep(animstart+2.5,animstart+4.8,iTime));//anim circle
    vec3 ret=max(tcol,a*(1.-lt)*redw);
    ret=max(ret,lt*dark);
    ret=max(ret,(1.-lt)*(1.-d)*red)*smoothstep(animstart-1.,animstart+0.35,iTime);
    float b=1.-circle(uv+vec2(0.,0.225*smoothstep(animstart,animstart-2.,iTime)),0.2242,0.22,true);
    tuv=uv;
    //tuv*=MD(-0.05-0.2*smoothstep(-0.25,0.85,uv.x));;
    //tuv.y+= ((cos(.85*tuv.x))-.975);
    float tuvy=mod(tuv.y,0.015)-0.0075;
    float e=1.-max(smoothstep(0.0005,0.0031,abs(tuvy)),step(0.195,tuv.y)+step(tuv.y,0.185)*step(0.165,tuv.y)+
               step(tuv.y,0.14)*step(0.06,tuv.y)+step(tuv.y,0.03)*step(0.015,tuv.y));
    //anim 1
    /*float di=floor(animstart+iTime*1.5); //anim
    di+=di>1.?1.:0.;
    di+=di>4.?5.:0.;
    di+=di>11.?1.:0.;
    float ir=mod(animstart+iTime*1.5,1.); //anim
    e*=1.-(max(step((-uv.y+di*(1.*0.015)+0.0075),0.0075),
           step(ir-0.5,uv.x)*step(abs(uv.y-di*(1.*0.015)+0.0075),0.0075)));*/
    
    //anim 2
    float di=smoothstep(animstart+4.5,animstart+6.5,iTime); //anim
    float di2=smoothstep(animstart+8.5,animstart+9.5,iTime);
    e*=step(uv.x+1.5*uv.y*(1.-di),di-0.5);
    e*=step(di2-.5,uv.x-2.*uv.y*(1.-di2));
    
    e=(1.-e)*(b);
    ret=max(ret,(1.-lt)*e*white);
    float c=1.-circle(uv,0.3542,0.35,true);
    tuvy=(mod(uv.y,0.026+0.1*smoothstep(-.5,0.5,uv.y))-0.013-0.05*smoothstep(-.5,0.5,uv.y));
    e=smoothstep(0.001,0.0051,abs(tuvy));
    e=((step(uv.y,-0.109))*c*(1.-e*step(uv.y,-0.109)));
    e*=step(abs(uv.x),0.5*smoothstep(animstart+1.5,animstart+3.,iTime)); //anim bot lines
    ret=max(ret,red*e);
    tuv=uv;
    tuv*=MD(3.3-sin(01.0-cos(2.0*smoothstep(animstart+4.25,animstart+5.5,iTime)))); //anim pl2
    tuv+=vec2(0.35521,0.);
    float f=1.-circle(tuv,0.0270,0.35,true);
    ret=max(ret,f*redw*(1.-lt));
    tuv=uv;
    tuv*=MD(-0.3+01.*smoothstep(animstart+2.,animstart+4.8,iTime));
    tuv+=vec2(0.2242,0.);
    //float fa=f;
    f=1.-circle(tuv,0.0570,0.35,true);
    ret=max(ret*(1.-(1.-lt)*f),(1.-lt)*f*dark*(1.-lt));
    ret=max(ret,strucb(uv));
    //ret=postfx(uv,ret,max(c,fa));
    f*=animendfade();
    return max(dark,max(ret*animendfade(),
               max((1.-f)*b*white*(1.-animendfade()),max((1.-f)*b*white*(1.-lt)*animendfades(),
                   (1.-f)*b*white*(lt)*(1.-animendfade()))))); //anim
}

float fin(vec2 p){
    return smoothstep(0.48,0.49,length(p));
}

float animm(){
	float animstart=6.5;
    return smoothstep(animstart,animstart+1.5,iTime);
}

vec4 mainImage(in vec2 uv )
{
    float Range = 10.;
	vec3 retcol=vec3(0.);
	if(iTime<28.){
    //anim
	float Line_Smooth	= animm()*
        pow(smoothstep(Range,Range-.05,2.*Range*(abs(smoothstep(.0, Range,uv.x+.5 )-.5))),.2);                         

    
    float rndx=iTime;
    rndx=100.;
    rndx*=20.;
    float Factor_T    =floor(rndx);
    float Factor_X    =xRandom(uv.x*.0021);
    float Amplitude1  =0.5000 * noise(Factor_X, Factor_T)
         			  +0.2500 * noise(Factor_X, Factor_T)
          			  +0.1250 * noise(Factor_X, Factor_T)
    	  			  +0.0625 * noise(Factor_X, Factor_T);
	Factor_X    	  =xRandom(uv.x*.0031+.0005);
    float Amplitude2  =0.5000 * noise2(Factor_X, Factor_T)
         			  +0.2500 * noise2(Factor_X, Factor_T)
          			  +0.1250 * noise2(Factor_X, Factor_T)
    	  			  +0.0625 * noise2(Factor_X, Factor_T);
    
    vec2 p=uv;
    p.y+=((cos(.5*p.x-0.15))-.975)*animm(); //anim
    float Light_Track  = line(vec2(p.x,p.y*2.+(Amplitude2-.5)*.12*Line_Smooth), .005, .0);
   	float Light_Track2  = line(vec2(uv.x,uv.y+(Amplitude2-.5)*.16*Line_Smooth), .005, .0);
   

	vec3 red=vec3(0.415,00.211,0.172);
	vec3 redw=vec3(0.992,0.509,0.466);
	vec3 white=vec3(0.611,0.878,0.819);
	vec3 dark=vec3(0.101,0.074,0.129);
	float animstart=6.5;
	float PI=(4.0 * atan(1.0));
	float TWO_PI=PI*2.;
	
	vec3 line1 =  Light_Track*dark;
    //vec4 line2 =  vec4(Light_Track2)*Light_Color2;
    
    retcol=map(uv,Light_Track);
	}
    vec4 fragColor =vec4(retcol,1.-fin(uv));
    if(iTime>25.){
        vec4 ttxx=texture(iChannel0,vec2((uv+0.5).x,1.-(uv+0.5).y))*smoothstep(26.,27,iTime);
        fragColor=mix(fragColor*smoothstep(26.,25,iTime),ttxx,ttxx.a);
    }
	fragColor.a*=smoothstep(2.,3.5,iTime);
	return fragColor;
}


void fragment() {
	vec4 tc=mainImage(UV.yx-0.5);
	ALBEDO=tc.rgb;
	ALPHA=tc.a;
}
