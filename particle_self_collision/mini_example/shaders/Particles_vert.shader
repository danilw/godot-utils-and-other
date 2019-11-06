shader_type particles;
render_mode disable_velocity,disable_force;

uniform float scale_v;
uniform float scr_posx;
uniform float scr_posy;
uniform sampler2D iChannel0; //position+ID

//because bug https://github.com/godotengine/godot/issues/33134
//this moved to Vertex shader of particle, out of transform feedback
//uniform sampler2D iChannel1; //values/data for ID


float decodeval_vel(int varz) {
    int iret=0;
    iret=varz>>8;
    int gxffff=65535;
    return float(iret)/float(gxffff);
}

float decodeval_pos(int varz) {
    int iret=0;
    iret=varz>>4;
    int gxfffff=1048575;
    return float(iret)/float(gxfffff);
}

vec4 getV(in ivec2 p){
    int max_pos=(640*3); //resx*SIZE
    vec4 tval=texelFetch( iChannel0, ivec2(p), 0 );
	if(tval.x<0.)return vec4(-1.,0.,0.,0.);
    float p1=decodeval_pos(int(tval.x))*float(max_pos);
    float p2=decodeval_pos(int(tval.y))*float(max_pos);
    float v1=decodeval_vel(abs(int(tval.z)));
    float v2=decodeval_vel(abs(int(tval.w)));
    float si=1.;
    if(tval.z<0.)si=-1.;
    float si2=1.;
    if(tval.w<0.)si2=-1.;
    vec2 unp=vec2(si*v1,si2*v2);
	return vec4(vec2(p1,p2),unp.xy);
}

ivec2 extra_dat_vel(ivec2 p){
	vec4 tval=texelFetch( iChannel0, ivec2(p), 0 );
	int gxff=255;
	return ivec2(abs(int(tval.z))&gxff,abs(int(tval.w))&gxff);
}

ivec2 extra_dat_pos(ivec2 p){
	vec4 tval=texelFetch( iChannel0, ivec2(p), 0 );
	int gxf=15;
	return ivec2(int(tval.x)&gxf,int(tval.y)&gxf);
}

int get_id(ivec2 p){
    ivec2 v1=extra_dat_pos(p);
    ivec2 v2=extra_dat_vel(p);
    int iret=(v1[0]<<20)|(v1[1]<<16)|(v2[0]<<8)|(v2[1]<<0);
    return iret;
}

ivec2 index_x(int id){
	ivec2 p_res=ivec2(640,360);
	int x=id%p_res.x;
	int y=id/p_res.x;
	return ivec2(x,y);
}

//vec4 get_data_by_id(int id){
//	return texelFetch(iChannel1,index_x(id),0);
//}

//used only CUSTOM to send data [id,type,posx,posy]
//can be used also COLOR to send more data, or just read data texture in fragment shader

void vertex() {
	float SIZE = 3.0;
	float BALL_SIZE = 0.90 * SIZE;
	ivec2 p_res=ivec2(640,360);
	if(scale_v>=0.99)SIZE*=21.6;
	float mn=1.5;//ivec2 p_res=ivec2(640,360);+1
	if(scale_v>=0.99)mn+=-1.;
	SIZE*=mn;
	float scale=mix(0.1,SIZE,scale_v);
	
	ivec2 tp=index_x(INDEX);
	vec4 ball  = getV(tp);
	vec2 p = ball.xy;
	vec2 vel = ball.zw;
	int idx=0;
	int typex=0;
	if(p.x<0.){
		p.x=-10000.-float(INDEX*10);
	}else{
		idx=get_id(tp);
		//vec4 dat=get_data_by_id(idx);
		vec4 dat=vec4(0.);
		typex=int(dat.x);
	}
	
	vec2 tppx=((vec2(-scr_posx*float(p_res.x),-scr_posy*float(p_res.y))*BALL_SIZE)/scale)*8.*2.872;
	if(scale_v>=0.99)tppx*=0.;
	TRANSFORM[3].xy =((p*BALL_SIZE)/scale)*8.+tppx;
	TRANSFORM[3].z = 0.0;
	
	CUSTOM=vec4(float(idx),float(typex),p);
	
	COLOR=vec4(0.);
}

