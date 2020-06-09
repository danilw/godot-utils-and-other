shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform sampler2D texture_albedo : hint_albedo;


void vertex() {
	
}

float floor_grid(vec2 p) {
    vec2 e = min(vec2(1.0), fwidth(p)); 
	vec2 a = 1.-smoothstep(1.0 - e, vec2(1.001), fract(p));
	vec2 b = smoothstep(vec2(0.0), e + 0.001, fract(p));
    vec2 l = (1.-(clamp((a + b),0.,2.) - (1.0 - e)))*clamp(1.0 - 8.*e,0.,1.);
    return clamp(((l.x + l.y) ),0.,1.);
}

void fragment() {
	vec2 tuv = UV;
	vec2 p = tuv;
	float fgr=floor_grid(tuv*6.);
	
	vec3 col = texture(texture_albedo,tuv).rgb;
	col=clamp(col+1.5*fgr*col.r,0.,1.);
	ALBEDO = 1.*col;
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	EMISSION = 0.5*col;
}
