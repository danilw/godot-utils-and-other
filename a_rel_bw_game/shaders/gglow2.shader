shader_type spatial;
render_mode blend_add,depth_draw_never,cull_back,unshaded;
uniform vec4 color:hint_color;

void fragment() {
	ALBEDO = 5.*color.rgb;
	
	float intensity = pow(0.022 + max(dot(NORMAL, normalize(VIEW)),0.), 02.85);
	ALBEDO*=intensity;
	ALPHA=0.0+intensity;

}