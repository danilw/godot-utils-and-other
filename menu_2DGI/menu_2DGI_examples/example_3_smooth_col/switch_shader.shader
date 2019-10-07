shader_type canvas_item;

uniform sampler2D texture_orig;
uniform sampler2D texture_glow1;
uniform sampler2D texture_glow2;
uniform sampler2D texture_glow3;
uniform sampler2D texture_glow4;

uniform float glow1;
uniform float glow2;
uniform float glow3;
uniform float glow4;
uniform float glowg;


void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution) {
	vec2 uv=fragCoord/iResolution;
	vec3 col=texture(texture_orig,uv).rgb;
	vec3 col2=texture(texture_glow1,uv).rgb;
	vec3 col3=texture(texture_glow2,uv).rgb;
	vec3 col4=texture(texture_glow3,uv).rgb;
	vec3 col5=texture(texture_glow4,uv).rgb;
	vec3 res_c=vec3(0.);
	res_c=col*glowg;
	res_c=max(res_c,col2*glow1);
	res_c=max(res_c,col3*glow2);
	res_c=max(res_c,col4*glow3);
	res_c=max(res_c,col5*glow4);
	fragColor=vec4(res_c,1.);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}