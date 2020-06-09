
shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;

void vertex() {
	POINT_SIZE=2.;
	COLOR=vec4(INSTANCE_CUSTOM.rgb,1.);
}

void fragment() {
	vec2 tuv = UV;
	
	ALBEDO = vec3(0.);
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	EMISSION = COLOR.rgb*1.;
}
