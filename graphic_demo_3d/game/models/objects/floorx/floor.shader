shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform sampler2D tx_x : hint_albedo;
uniform sampler2D to_o : hint_albedo;


varying vec3 ocol;

void vertex() {
	COLOR=vec4(INSTANCE_CUSTOM.brg*vec3(1.,0.5,0.5),1.);
	ocol=INSTANCE_CUSTOM.rgb;
}

void fragment() {
	vec2 tuv = UV;
	float baa=(length(VERTEX)-2.5);
	baa=1.-clamp(baa,0.,1.);
	
	vec3 col = texture(tx_x,tuv).rgb;
	vec3 col2 = texture(to_o,tuv).rgb;
	ALBEDO = col;
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	EMISSION = mix(col2*ocol,pow(col2*COLOR.rgb,vec3(2.)),baa);
}
