shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform float scale_v;
uniform bool clean_scr;
uniform bool clean_scr5;
uniform bool clean_scr10;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform float scr_posx;
uniform float scr_posy;
uniform float speed_x;
uniform int last_index;
uniform bool spawn1;
uniform bool spawn2;
uniform vec2 gravity;
uniform vec3 iMouse;

// base on https://www.shadertoy.com/view/wdG3Wd

// data
// in [x,y,z,w]
// x-0xfffff-posx, 0xf-data
// y-0xfffff-posy, 0xf-data
// z-0xffff-velx, 0xff-data
// w-0xffff-vely, 0xff-data
// data used to store particle IDs

// this is godot port, original code https://www.shadertoy.com/view/tstSz7

ivec2 index_x(int id){
	ivec2 p_res=ivec2(640,360);
	int x=id%p_res.x;
	int y=id/p_res.x;
	return ivec2(x,y);
}

bool is_alive(int id){
	if(texelFetch(iChannel1,index_x(id),0).y>0.)return true;
	return false;
}

float decodeval_vel(int varz) {
    int iret=0;
    iret=varz>>8;
    int gxffff=65535;
    return float(iret)/float(gxffff);
}

int encodeval_vel(ivec2 colz) {
    int gxffff=65535;
    int gxff=255;
    return int(((colz[0]&gxffff)<< 8)|((colz[1]&gxff)<< 0));
}

float decodeval_pos(int varz) {
    int iret=0;
    iret=varz>>4;
    int gxfffff=1048575;
    return float(iret)/float(gxfffff);
}

int encodeval_pos(ivec2 colz) {
    int gxfffff=1048575;
    int gxf=15;
    return int(((colz[0]&gxfffff)<< 4)|((colz[1]&gxf)<< 0));
}


// get [pos,vel]
vec4 getV(in vec2 p){
    int max_pos=(640*3); //resx*SIZE
    if (p.x < 0.001 || p.y < 0.001) return vec4(0);
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

ivec2 extra_dat_vel(vec2 p){
    vec4 tval=texelFetch( iChannel0, ivec2(p), 0 );
    int gxff=255;
    return ivec2(abs(int(tval.z))&gxff,abs(int(tval.w))&gxff);
}

ivec2 extra_dat_pos(vec2 p){
    vec4 tval=texelFetch( iChannel0, ivec2(p), 0 );
    int gxf=15;
    return ivec2(int(tval.x)&gxf,int(tval.y)&gxf);
}

// get saved unique ID
int get_id(vec2 p){
    ivec2 v1=extra_dat_pos(p);
    ivec2 v2=extra_dat_vel(p);
    int iret=(v1[0]<<20)|(v1[1]<<16)|(v2[0]<<8)|(v2[1]<<0);
    return iret;
}

ivec4 save_id(int id){
    int gxff=255;
    int gxf=15;
    int a=(id>>20)&gxf;
    int b=(id>>16)&gxf;
    int c=(id>>8)&gxff;
    int d=(id>>0)&gxff;
    return ivec4(a,b,c,d);
}

vec2 pack_pos(vec2 pos,ivec2 extra_val){
    int max_pos=(640*3); //resx*SIZE
    int gxfffff=1048575;
    int v1=max(int((pos.x/float(max_pos))*float(gxfffff)),0);
    int v2=max(int((pos.y/float(max_pos))*float(gxfffff)),0);
    float px=float(encodeval_pos(ivec2(v1,extra_val.x)));
    float py=float(encodeval_pos(ivec2(v2,extra_val.y)));
    return vec2(px,py);
}

vec2 pack_vel(vec2 vel,ivec2 extra_val){
    int gxffff=65535;
    int v1=abs(int(vel.x*float(gxffff)));
    int v2=abs(int(vel.y*float(gxffff)));
    float vx=float(encodeval_vel(ivec2(v1,extra_val.x)));
    float vy=float(encodeval_vel(ivec2(v2,extra_val.y)));
    float si=1.;
    if(vel.x<0.)si=-1.;
    float si2=1.;
    if(vel.y<0.)si2=-1.;
    return vec2(vx*si,vy*si2);
}

// save everything to pixel color
vec4 save_all(vec2 pos, vec2 vel, int id){
    ivec4 tid=save_id(id);
    ivec2 extra_data_pos=tid.xy;
    ivec2 extra_data_vel=tid.zw;
    vec2 pos_ret=pack_pos(pos,extra_data_pos);
    vec2 vel_ret=pack_vel(vel,extra_data_vel);
    return vec4(pos_ret,vel_ret);
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 spawn_p(vec2 middle,vec2 fragCoord){
	if((iMouse.z<0.5)||(iFrame%3!=0))return vec4(-1.,0.,0.,0.);
	float SIZE = 3.0;
	float tg=1.;
	if(scale_v>=0.99)tg=1./21.6;
	ivec2 p_res=ivec2(640,360);
	vec2 im=vec2(p_res)/(vec2(1280.,720.))+1.; //0.5+1
	if(scale_v>=0.99)im+=-1.;
	vec2 tppx=vec2(scr_posx*float(p_res.x),scr_posy*float(p_res.y));
	if(scale_v>=0.99)tppx*=0.;
	vec2 mouseDir = middle.xy - (iMouse.xy+(tppx*3.*8.*0.9*1.92)/mix(0.01,SIZE,scale_v))*mix(0.01,SIZE,scale_v)*1./(3.*8.*0.9*tg)*im;
	float d=1.5;
	if(spawn2)d=4.;
	if(length(mouseDir)<=d){
		int id=last_index;
		vec2 pos=(middle+ (rand(fragCoord)-0.5)* SIZE*0.25);
		vec2 vel=vec2(0.);
		return save_all(pos,vel,id);
		}
	return vec4(-1.,0.,0.,0.);
}

void sim_step( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    float SIZE = 3.0;
    float BALL_SIZE = 0.90 * SIZE; // should be between sqrt(2)/2 and 1
    float BALL_D = 2.0 * BALL_SIZE; 
    int H = 340; // Reduce this if you want to play with surface or reduce pressure at the bottom
    float VEL_LIMIT = 0.3 * BALL_SIZE;
    vec2 G = gravity;//vec2(0.0, -0.006); // 0.006
    float E_FORCE = .9;
    float M = 0.6 * BALL_SIZE;
    float DAMP_K = 0.98;
    float SQ_K = 0.0;
    float MOUSE_F = mix(0.008,0.418,scale_v);
    vec2 middle = SIZE * (fragCoord);
    int self_id=0;
    if (iFrame <= 10 || clean_scr || clean_scr5 || clean_scr10) {
        ivec2 iv = ivec2(fragCoord);
            //init
			if(clean_scr){
				fragColor = vec4(-1.,0.,0.,0.);
			}
			else if (((iv.x + iv.y) %2 == 0)&&(clean_scr5)){
				if((iv.x+iv.y*int(iResolution.x))<(100000)){
					int id=int(floor(fragCoord.x)+floor(fragCoord.y)*iResolution.x)/2;
					vec2 pos=(middle+ (rand(fragCoord)-0.5)* SIZE*0.25);
					vec2 vel=vec2(0.);
					fragColor = save_all(pos,vel,id);
				}
				else{
					fragColor = vec4(-1.,0.,0.,0.);
				}
			}
			else if (((iv.x + iv.y) %2 == 0)&&(clean_scr10)){
				if((iv.x+iv.y*int(iResolution.x))<(200000)){
					int id=int(floor(fragCoord.x)+floor(fragCoord.y)*iResolution.x)/2;
					vec2 pos=(middle+ (rand(fragCoord)-0.5)* SIZE*0.25);
					vec2 vel=vec2(0.);
					fragColor = save_all(pos,vel,id);
				}
				else{
					fragColor = vec4(-1.,0.,0.,0.);
				}
			}
			else if ((iv.x + iv.y) %2 == 0 && iv.y % 2 == 0 && iv.y < H) {
				int id=int(floor(fragCoord.x)+floor(fragCoord.y-fragCoord.y/2.)*iResolution.x)/2;
				vec2 pos=(middle+ (rand(fragCoord)-0.5)* SIZE*0.25);
				vec2 vel=vec2(0.);
				fragColor = save_all(pos,vel,id);
			}
			else {
            fragColor = vec4(-1.,0.,0.,0.);
        }
    } else {
        // check if ball needs to transition between cells
        vec4 v = vec4(0.); 
        vec2 lp=vec2(-10.);
        bool br=false;
        for (int x=-1; x<=1; x++) {
            if(br)break;
            for (int y=-1; y<=1; y++) {
                vec2 np = fragCoord + vec2(float(x),float(y));
                vec4 p = getV(np);
                //found ball for transition
                if(trunc(middle/SIZE) == trunc(p.xy/SIZE)){
                    v = p;
                    lp=np;
                    br=true;
                    break;
                }
            }
        }

        // movement calculations
        if (br){
            self_id=get_id(trunc(lp.xy));
			if(!is_alive(self_id)){
				if(spawn1||spawn2)
					fragColor = spawn_p(middle,fragCoord);
				else
					fragColor = vec4(-1.,0.,0.,0.);
				return;
			}
            vec2 dr = vec2(0);//vec2(0.0, -0.01);

            // collision checks
            float stress = 0.0;
            for (int x=-2; x<=2; x++) {
                for (int y=-2; y<=2; y++) {
                    if (x !=0 || y != 0) 
                    {
                        vec4 p = getV(fragCoord + vec2(float(x),float(y)));
                        if (p.x > 0.0) {
                            vec2 d2 = v.xy - p.xy;
                            float l = length(d2);
                            float f = BALL_D - l;
                            if (l >= 0.001* BALL_SIZE &&  f > 0.0) {
                                float f2 = f / (BALL_D);
                                f2 +=  SQ_K*f2*f2;
                                f2 *= BALL_D;
                                vec2 force_part = E_FORCE * normalize(d2)*f2;
                                stress += abs(force_part.x)+abs(force_part.y);
                                dr += force_part;
                            }
                        }
                    }
                }
            }

            // force from mouse
			float tg=1.;
			if(scale_v>=0.99)tg=1./21.6;
			ivec2 p_res=ivec2(640,360);
			vec2 im=vec2(p_res)/(vec2(1280.,720.))+1.; //0.5+1
			if(scale_v>=0.99)im+=-1.;
			vec2 tppx=vec2(scr_posx*float(p_res.x),scr_posy*float(p_res.y));
			if(scale_v>=0.99)tppx*=0.;
            vec2 mouseDir = v.xy - (iMouse.xy+(tppx*3.*8.*0.9*1.92)/mix(0.01,SIZE,scale_v))*mix(0.01,SIZE,scale_v)*1./(3.*8.*0.9*tg)*im;
            float d2 = dot(mouseDir, mouseDir);
            dr += M * MOUSE_F *
                max(stress, 1.0) *
                clamp(iMouse.z, 0.0, 1.0) * // mouse clicked outside zoom region
                mouseDir * BALL_SIZE / max(d2, 0.01); //  normalize(mouseDir) / (length(mouseDir)/BALL_SIZE)

            // movement calculation
            vec2 pos = v.xy;
            float damp_k = length(dr)>0.001? DAMP_K : 1.0; // don't apply damping to freely flying balls
            dr += G * M; // gravity
            vec2 vel = damp_k * v.zw + dr / M;
            vel = clamp(vel, vec2(-1.0), vec2(1.0));

            vec2 dpos = vel * VEL_LIMIT;
            pos += dpos*speed_x;
            v.xy = pos;
            v.xy = clamp(v.xy,vec2(BALL_SIZE *(1.0 + sin(pos.y)*0.1),BALL_SIZE),SIZE*iResolution.xy-vec2(BALL_SIZE));
            
            //pack everything
            v=save_all(v.xy,vel,self_id);
            fragColor = v; 
        } else {
            if(spawn1||spawn2)
				fragColor = spawn_p(middle,fragCoord);
			else
				fragColor = vec4(-1.,0.,0.,0.);
        }
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    sim_step(fragColor, fragCoord, iResolution);
}

void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	
	mainImage(COLOR,UV*iResolution,iResolution);
}
