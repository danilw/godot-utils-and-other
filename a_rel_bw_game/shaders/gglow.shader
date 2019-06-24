shader_type spatial;
render_mode blend_add,depth_draw_always,cull_back,unshaded;

void fragment() {
	ALBEDO = 1.*vec3(1, 1, 1);
	
	float intensity = pow(0.522 + dot(NORMAL, normalize(VIEW)), 010.85);
	ALPHA=0.0+intensity;

}