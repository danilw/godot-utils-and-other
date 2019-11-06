shader_type canvas_item;
render_mode blend_mix;

uniform float iTime;
uniform int iFrame;
uniform float scale_v;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform sampler2D iChannel4;//because of bug https://github.com/godotengine/godot/issues/33134
uniform vec3 iMouse;

varying vec2 id_type;
varying vec2 pos_p;

ivec2 index_x(int id){
	ivec2 p_res=ivec2(640,360);
	int x=id%p_res.x;
	int y=id/p_res.x;
	return ivec2(x,y);
}

vec4 get_data_by_id(int id){
	return texelFetch(iChannel4,index_x(id),0);
}

void vertex(){
	float SIZE = 3.0;
	if(scale_v>=0.99)SIZE*=21.6;
	float mn=1.5;//ivec2 p_res=ivec2(640,360);+1
	if(scale_v>=0.99)mn+=-1.;
	SIZE*=mn;
	float scale = mix(0.1,SIZE,scale_v);
	VERTEX.xy=VERTEX.xy / scale;
	id_type=INSTANCE_CUSTOM.xy;
	//because of bug https://github.com/godotengine/godot/issues/33134
	id_type.y=get_data_by_id(int(id_type.x)).x;
	pos_p=INSTANCE_CUSTOM.zw;
}

vec4 get_tex_byid(vec2 p, int typex){
	vec4 retc=vec4(0.);
	if(typex==0){
		return retc;
	}
	typex=typex-1;
	if(typex<9){
		p*=(1./3.);
		p+=vec2(float(typex%3),float(typex/3))*(1./3.);
		retc=texture(iChannel0,p);
	}
	else{
		typex=typex%9;
		p*=(1./3.);
		p+=vec2(float(typex%3),float(typex/3))*(1./3.);
		retc=texture(iChannel1,p);
	}
	return retc;
}

//using https://www.shadertoy.com/view/llyXRW

void C(inout vec2 U, inout vec4 T, in int c){
    U.x+=.5;	
    if(U.x<.0||U.x>1.||U.y<0.||U.y>1. ){
        T+= vec4(0);
    }
    else{
        vec2 tu=U/16. + fract( vec2(float(c), float(15-c/16)) / 16.);
		tu.y=1.-tu.y;
        T+= textureGrad( iChannel3,tu, dFdx(tu/16.),dFdy(tu/16.));
    }
}

// X dig max
float print_int(vec2 U, int val) {
    vec4 T = vec4(0);
    int cval=val;
    int X=8;
    for(int i=0;i<X;i++){
            if(cval>0){
        int tv=cval%10;
        C(U,T,48+tv);
        cval=cval/10;
    }
    else{
        if(length(T.yz)==0.)
            return -1.;
        else return T.x;
    }
    }

    if(length(T.yz)==0.)
        return -1.;
    else return T.x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ,in vec2 iResolution)
{
	vec2 uv=fragCoord/iResolution;
	fragColor=get_tex_byid(uv,int(id_type.y));
	if(scale_v<0.48){
		int val=int(id_type.x);//16777215;
		uv.y=1.-uv.y;
	    float c=print_int((uv-0.5-vec2(0.25,-0.15))*7.,val);
		c=clamp(c,0.,1.);
		fragColor=fragColor*(1.-c)+vec4(.82,0.2,02.,1.)*(c);
	}
}

void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	mainImage(COLOR,UV*iResolution,iResolution);
}