shader_type spatial;
render_mode blend_mix,depth_draw_never,cull_back,unshaded;
uniform sampler2D tex_panorama : hint_albedo;

void vertex() {
	
}

void fragment() {
	vec2 tuv=UV;
	tuv.x=-tuv.x;
	tuv.x=-0.5+tuv.x;
	tuv=fract(tuv);
	vec4 albedo_tex = texture(tex_panorama,tuv);
	ALPHA=1.;
	ALBEDO = albedo_tex.rgb;

}