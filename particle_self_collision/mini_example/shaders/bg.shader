shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform float scale_v;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec3 iMouse;

void mainImage( out vec4 fragColor, in vec2 fragCoord ,in vec2 iResolution)
{
	
    float SIZE = 3.0;
	float scale = mix(0.1,SIZE,scale_v);
	vec2 uv=fragCoord/iResolution;
	uv*=iResolution.xy/iResolution.y;
	fragColor=texture(iChannel0,uv*scale);

}
void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	mainImage(COLOR,UV*iResolution,iResolution);
}