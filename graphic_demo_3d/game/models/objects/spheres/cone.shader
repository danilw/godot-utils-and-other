shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform float iTime;
uniform float blenda;
uniform float blendb;

void vertex() {
	
}

float floor_grid(vec2 p) {
    vec2 e = min(vec2(1.0), fwidth(p)); 
	vec2 a = 1.-smoothstep(1.0 - e, vec2(1.001), fract(p));
	vec2 b = smoothstep(vec2(0.0), e + 0.001, fract(p));
    vec2 l = (0.5*(clamp((a + b),0.,2.) - (1.0 - e)))*clamp(1.0 - 3.*e,0.,1.);
    return clamp(((l.x + l.y) ),0.,1.);
}

void fragment() {
	vec2 tuv = UV;
	METALLIC = 0.0;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	
	vec3 col=vec3(0);
	if(blenda>0.){
		int d=int(tuv.x*80.);
		
		tuv*=vec2(10.,1);
		vec2 ouv=tuv;
		tuv=floor(tuv*80.)/80.;
		vec2 offset = round(tuv*20.)/20.;
	    col=vec3(0.);
	    for(int i = 0; i < 3; i++) {
	        float t = iTime + float(i)*5.1 + (abs(tuv.y))*6.5;
	        float r = (pow(sin(t), 3.0) + 1.0) * 0.02;
	        
	        if(length(tuv - offset) < r+0.001) {
				if(i==0)col.x = (1.);
				if(i==1)col.yz = vec2(1.);
				if(i==2)col.z = 1.;
	        }
		}
		col*=vec3(floor_grid(ouv*20.+0.375));
		
		col*=1.-smoothstep(0.,4.,abs(float(d%10)-4.5));
		col*=1.-smoothstep(0.,0.001,(.5-UV.y-blenda*0.5));
		col*=1.-smoothstep(0.,0.001,-(.5-UV.y-blendb*0.5));
	}
	ALBEDO=vec3(0);
	EMISSION=col*1.5;
	
}
