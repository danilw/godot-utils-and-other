shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform sampler2D tx_o : hint_albedo;

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

const vec3 col_o=vec3(0.79,0.43,1.);

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
	vec2 tuv = UV;
	METALLIC = 0.0;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	
	vec3 col=vec3(0);
	vec3 cx=col_o*power;
	
	vec2 p = tuv;
	col=texture(tx_o,tuv).rgb;
	
	float fgr=floor_grid(p*13.);
	col=vec3(0.)+clamp((fgr*1.5*pow(col.r,1.)),0.,1.)*0.15*cx;
	ALBEDO=col;
	EMISSION=col;
	
}
