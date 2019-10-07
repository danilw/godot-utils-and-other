shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1:hint_albedo;
uniform sampler2D iChannel2:hint_albedo;
uniform sampler2D iChannel3:hint_albedo;

uniform vec2 l_res;
uniform bool render;
uniform bool render2;
uniform bool render3;


void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution) {
	vec2 res = iResolution.xy / iResolution.y;
	float dv=l_res.y;
	if(res.x<l_res.x/l_res.y)dv=l_res.x;
	vec2 res2 = l_res/dv-(l_res/dv)/2.;
	if(res.x<l_res.x/l_res.y)res2*=res.x;
	vec2 uv = (fragCoord.xy) / iResolution.y - res/2.0;
	vec3 col=vec3(0.);
	if(!render3)
	col=texture(iChannel0,uv).rgb;
	else col=vec3(1.);
	col*=step(abs(uv.x),res2.x)*step(abs(uv.y),res2.y);
	if(!render){
	if(render2)
	col=mix(col*=0.95,clamp(texture(iChannel3,((fragCoord.xy) / iResolution.xy)).rgb,vec3(0.),vec3(1.)),dot(col,vec3(1.))/3.);
	else
	col=mix(col*=0.95,clamp(texture(iChannel1,((fragCoord.xy) / iResolution.xy)).rgb,vec3(0.),vec3(1.)),dot(col,vec3(1.))/3.);
	}
	else
	{
	col=mix(col*=0.95,clamp(texture(iChannel2,((fragCoord.xy) / iResolution.xy)).rgb,vec3(0.),vec3(1.)),dot(col,vec3(1.))/3.);
	}
	fragColor = vec4(col,1.);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}