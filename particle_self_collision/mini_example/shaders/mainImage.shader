shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform float scale_v;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec3 iMouse;


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

vec4 ballD(in vec2 ipos, in vec2 ballp)
{
    float SIZE = 3.0;
    float BALL_SIZE = 0.90 * SIZE; // should be between sqrt(2)/2 and 1
    float d = distance(ipos, ballp)/BALL_SIZE;
    return vec4(clamp(sign(1.0-d), 0.0, 1.0)*(1.-d) * float(ballp.x > 0.0)) ;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
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

void mainImage( out vec4 fragColor, in vec2 fragCoord ,in vec2 iResolution)
{
    float SIZE = 3.0;
    float BALL_SIZE = 0.90 * SIZE; // should be between sqrt(2)/2 and 1
	
    float scale = mix(0.01,SIZE,scale_v);
	/*if(iMouse.z > 0.0 && iMouse.x < 30.0 ){
		scale= clamp(SIZE*(1.-iMouse.y/iResolution.y), 0.01, SIZE);
	}*/
    ivec2 cellIndex = ivec2((fragCoord / SIZE) * scale);
    vec2 cellp = mod(fragCoord, SIZE * scale)/(SIZE * scale);

    vec4 res = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 worldPos = fragCoord * scale;
    float overlaps = 0.0;
    vec4 normSum = vec4(0.0);
    for (int x=-1; x<=1; x++) {
        for (int y=-1; y<=1; y++) {
            
            ivec2 tp = max(cellIndex+ivec2(x,y), ivec2(0));
            
        	vec4 ball  = getV(tp);
            vec2 p = ball.xy;
            vec2 vel = ball.zw;
			if(p.x<0.)continue;
            
            float d=sdBox(worldPos-p.xy,vec2(BALL_SIZE)*.5);
            ///normSum += vec4(p.xy-worldPos, 0.0, 0.0)/BALL_SIZE*(d < 1.0 ? 1.0 : 0.0);
            vec4 shade = vec4(clamp(sign(1.0-d), 0.0, 1.0)*(1.-d) * float(ball.x > 0.0)) ;
            
            int self_id=get_id(tp);
            int sx=self_id%int(iResolution.x);
            int sy=(self_id/int(iResolution.x));
            shade.r*=(float(sx%20)/20.);
            shade.g*=(float(sy%20)/20.);
            shade.b*=0.25+0.75*(float(self_id)/(iResolution.x*iResolution.y));
            
            //vec4 shade = vec4(nc(worldPos-p.xy),1.);
            
            //vec4 shade = vec4(d < 1.0 ? 1.0 : 0.0) ;
            //res=max(res, shade*vec4(vel.x,-vel.x-vel.y,vel.y, 1.0));
            res=max(res, shade);
            //overlaps += d < 1.0 ? 1.0 : 0.0;
        }
    }
    fragColor = res;
    //fragColor = res * vec4(2.0 - overlaps, 3.0 - 2.0*overlaps, 1.0, 1.0);
    //fragColor = normSum+vec4(1.0, 1.0, 1.0,1.0)*0.5;
    //fragColor = texture(iChannel0,fragCoord/iResolution.xy);
    //fragColor.gb*=(float(abs(int(fragColor.w))&0xff)/float(0xff));

}
void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	mainImage(COLOR,UV*iResolution,iResolution);
}