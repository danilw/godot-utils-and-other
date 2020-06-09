shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform sampler2D tx_o : hint_albedo;
uniform sampler2D tx_b : hint_albedo;
uniform sampler2D tx_g : hint_albedo;
uniform sampler2D tx_r : hint_albedo;
uniform vec4 blendx;

const float power=1.25;

void vertex() {
	
}




void fragment() {
	vec2 tuv = UV;
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	
	vec3 col=vec3(0);
	vec3 c1=vec3(0);
	vec3 c2=vec3(0);
	vec3 c3=vec3(0);
	vec3 c4=vec3(0);
	
	if(blendx.x>0.)c1=texture(tx_o,tuv).rgb*power;
	if(blendx.y>0.)c2=texture(tx_b,tuv).rgb*power;
	if(blendx.z>0.)c3=texture(tx_g,tuv).rgb*power;
	if(blendx.w>0.)c4=texture(tx_r,tuv).rgb*power;
	col=c2*blendx.y+c3*blendx.z+c4*blendx.w;
	//col=clamp(col,0.,1.);
	col=c1*blendx.x+col;
	ALBEDO=col;
	EMISSION=col;
	
}
