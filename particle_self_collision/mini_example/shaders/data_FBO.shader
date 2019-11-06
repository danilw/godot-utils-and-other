shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform bool clean_scr;
uniform bool clean_scr5;
uniform bool clean_scr10;
uniform int update_id;
uniform int update_type;
uniform bool update_once;
uniform bool rem_once;
uniform int last_index;
uniform bool spawn1;
uniform bool spawn2;
uniform vec3 iMouse;

ivec2 index_x(int id){
	ivec2 p_res=ivec2(640,360);
	int x=id%p_res.x;
	int y=id/p_res.x;
	return ivec2(x,y);
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 spawn_at(in vec2 fragCoord){
	if(ivec2(fragCoord)==index_x(last_index)){
		return vec4(1.+trunc(17.*rand(fragCoord+mod(iTime,1000.))),1.,0.,0.);
	}
	else return texelFetch(iChannel0,ivec2(fragCoord),0);
}

// data per pixel
// pixel pos==particle ID
// [type,dead/alive,unused,unused]
void mainImage( out vec4 fragColor, in vec2 fragCoord ,in vec2 iResolution)
{
	if((spawn1||spawn2)&&((iMouse.z>0.5)&&(iFrame%3==0))){
		fragColor=spawn_at(fragCoord);
		return;
	}
	if(update_once){
		if(ivec2(fragCoord)==index_x(update_id)){
			fragColor=vec4(float(update_type),1.,0.,0.);
		}else{
			fragColor=texelFetch(iChannel0,ivec2(fragCoord),0);
		}
	}
	else
	if(rem_once){
		if(ivec2(fragCoord)==index_x(update_id)){
			fragColor=vec4(0.,-1.,0.,0.);
		}else{
			fragColor=texelFetch(iChannel0,ivec2(fragCoord),0);
		}
	}
	else
	if((clean_scr10)||(clean_scr5)||(clean_scr)||(iFrame<2))
	{
	if(clean_scr)
		fragColor=vec4(0.,-1.,0.,0.);
	else
	if((clean_scr5)||(clean_scr10))
		fragColor=vec4(1.+trunc(17.*rand(fragCoord+mod(iTime,1000.))),1.,0.,0.);
	else
		fragColor=vec4(1.+float(int((fragCoord.x)+floor(fragCoord.y)*iResolution.x)%18),1.,0.,0.);
	}
	else{
		fragColor=texelFetch(iChannel0,ivec2(fragCoord),0);
	}
}
void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	mainImage(COLOR,UV*iResolution,iResolution);
}