shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D p_o : hint_albedo;

void vertex() {
	
}

vec2 uv_sphere(vec3 v)
{
	float pi = 3.1415926536;
	vec2 uv=vec2(0.5 + atan(v.z, v.x) / (2.0 * pi), acos(v.y) / pi);
	uv.y=1.-uv.y;
	uv.x=-0.75+uv.x;
	uv=fract(uv);
	return uv;
}

void fragment() {
	
	vec3 rd=normalize(((WORLD_MATRIX*CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((WORLD_MATRIX*CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float baa=(length(((VERTEX)))-0.5)/15.;
	baa=clamp(baa,0.,1.)*0.0465;
	vec3 ref = reflect(rd,nor);
	vec2 tuv=uv_sphere(normalize(ref));
	
	vec3 col=vec3(0.);
	vec3 tot=vec3(0.);
	
	// bad antialiasing/mltisampling
	const int AA=4;
	if(baa>0.001){
		for (int mx = 0; mx < AA; mx++)
			for (int nx = 0 ; nx < AA; nx++) {
				vec2 o = vec2(float(mx), float(nx)) / float(AA) - 0.5;
				o=tuv+o*baa;
				tot+=texture(p_o,o).rgb;
			}
		tot /= float(AA * AA);
	}
	else tot=texture(p_o,tuv).rgb;
	col=pow(tot,vec3(1.25));

	float dx = smoothstep(0.05,0.25,max(dot(NORMAL, normalize(VIEW)),0.));
	col*=dx;
	ALBEDO=col;
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
	EMISSION=col*5.;
}
