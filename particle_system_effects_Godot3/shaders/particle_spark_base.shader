shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,unshaded;

uniform vec4 color:hint_color;
uniform sampler2D texture_gr:hint_albedo;

void vertex() {
	VERTEX.yz*=5.;
	VERTEX.x*=0.05;
}

void fragment() {
	vec4 col=texture(texture_gr,UV);
	ALBEDO=col.a*0.015*COLOR.a*(color.rgb/max(1.-col.a,0.001));
	//ALPHA=col.a*0.015*COLOR.a;
}