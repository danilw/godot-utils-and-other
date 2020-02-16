shader_type spatial;
render_mode blend_mix,depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec3 dir_angle;

vec3 sky(vec3 d) {
	vec3 c1=3.*vec3(0.4,0.34,0.3); // horizont color
	vec3 c2=2.5*vec3(.18,.28,.44); // sky color
	vec3 c3=vec3(0.01,0.05,0.15); // bot color
	vec3 c4=vec3(1., .7, .3); // sun color
	vec3 ldir = normalize(dir_angle);
	float sda = clamp(0.5 + 0.5*dot(d,ldir),0.0,1.0);
	float hor=1.-max(d.y,0.);
	float hor_power=pow(hor,4.0+ 8.0-8.0*sda); //horizont, remove if not needed
	vec3 col = mix(c1*100., c2*100., min(abs(d.y)*2. + .5, 1.)) / 255.*.5;
	col *= (1. + c4 / sqrt(length(d - ldir))*2.); //sun
	return mix(c3,clamp(col,vec3(0.),vec3(1.)),hor_power);
}


void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	vec3 sky_col=sky(rd);
	ALBEDO=sky_col;
	//ALBEDO=ALBEDO*ALBEDO; //to use in Godot GLES3 add this color correction
	
}
