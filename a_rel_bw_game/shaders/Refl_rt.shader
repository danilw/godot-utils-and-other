shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,unshaded;
uniform bool minif;
uniform bool disable_refl;
uniform bool disable_panorama;

uniform sampler2D Front : hint_albedo;
uniform sampler2D Right : hint_albedo;
uniform sampler2D Left : hint_albedo;
uniform sampler2D Back : hint_albedo;
uniform sampler2D Up : hint_albedo;
uniform sampler2D Down : hint_albedo;

uniform sampler2D tex_panorama : hint_albedo;

vec4 cubemap(in vec3 d)
{
	vec3 a = abs(d);
	bvec3 ip =greaterThan(d,vec3(0.));
	vec2 uvc;
	if (ip.x && a.x >= a.y && a.x >= a.z) {uvc.x = -d.z;uvc.y = d.y;
	return texture(Front,0.5 * (uvc / a.x + 1.));
	}else
	if (!ip.x && a.x >= a.y && a.x >= a.z) {uvc.x = d.z;uvc.y = d.y;
	return texture(Back,0.5 * (uvc / a.x + 1.));
	}else
	if (ip.y && a.y >= a.x && a.y >= a.z) {uvc.x = d.x;uvc.y = -d.z;
	return texture(Up,0.5 * (uvc / a.y + 1.));
	}else
	if (!ip.y && a.y >= a.x && a.y >= a.z) {uvc.x = d.x;uvc.y = d.z;
	return texture(Down,0.5 * (uvc / a.y + 1.));
	}else
	if (ip.z && a.z >= a.x && a.z >= a.y) {uvc.x = d.x;uvc.y = d.y;
	return texture(Right,0.5 * (uvc / a.z + 1.));
	}else
	if (!ip.z && a.z >= a.x && a.z >= a.y) {uvc.x = -d.x;uvc.y = d.y;
	return texture(Left,0.5 * (uvc / a.z + 1.));
	}
	return vec4(0.);
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


vec3 ref_panorama(vec3 ref) {
	vec2 tuv=uv_sphere(normalize(ref));
	vec4 albedo_tex = texture(tex_panorama,tuv,1.);
	return albedo_tex.rgb;

}

void fragment(){
	vec3 selfpos=((WORLD_MATRIX*vec4(1.0)).xyz);
	vec3 cam=((CAMERA_MATRIX*vec4(1.0)).xyz);
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 ref = reflect(rd,nor);
	if(!disable_refl){
	vec4 albedo_tex=cubemap(normalize(-ref)*vec3(-1.,1.,1.));
	ALPHA=1.;
	ALBEDO = albedo_tex.rgb;
	ALBEDO*=ALBEDO;
	ALPHA=1.;
	}
	else{
	if(!disable_panorama){
	ALBEDO = ref_panorama(ref);
	ALPHA=1.;
	}
	else{
	ALBEDO = vec3(0.1);
	ALPHA=1.;
	}
	}
	if(minif)ALBEDO=vec3(0.);
}