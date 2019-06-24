shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back;
uniform sampler2D tex_panorama : hint_albedo;
uniform float ctime;
uniform float iTime;
uniform bool disable_panorama;

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
	vec3 selfpos=((WORLD_MATRIX*vec4(1.0)).xyz);
	vec3 cam=((CAMERA_MATRIX*vec4(1.0)).xyz);
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
	
	vec2 tuv=uv_sphere(normalize(ref));
	vec4 albedo_tex = texture(tex_panorama,tuv,1.);
	METALLIC=0.;
	ALPHA=1.+smoothstep(ctime,ctime+1.,iTime);
	ALBEDO = pow(albedo_tex.rgb*3.,vec3(2.));
	if(disable_panorama){
		ALBEDO = vec3(0.474,0.658,0.832);
	}

}