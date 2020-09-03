shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;

uniform int material_id;

const float dv=0.25;
float encode_mid(int mid){
	vec2 val=vec2(0.);
	return float(mid+1)*dv+dv*0.5;
}

int decode_mid(float mid){
	if(mid<dv){
		return -1;
	}
	return int(mid/dv)-1;
}

void vertex() {
    COLOR=vec4(0.,0.,0.,1.);
	COLOR.r=encode_mid(material_id);
}

void fragment() {
	ALBEDO =  COLOR.rgb;
}
