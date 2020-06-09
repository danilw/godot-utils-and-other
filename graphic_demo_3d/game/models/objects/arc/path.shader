shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D iChannel0:hint_black;
uniform ivec2 ppos;
uniform ivec2 ppos2;
uniform float delta;

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    vec2 uv = fragCoord/iResolution.xy;
	ivec2 ipx=ivec2(fragCoord);
	vec4 ocol=texelFetch(iChannel0,ipx,0);
	float a=ocol.r;
	float b=ocol.g;
	float c=ocol.b;
	float d=ocol.a;
	if((ppos==ipx)||(ppos2==ipx)){
		b=1.;
		c=min(c+delta*2.,13.);
		d=min(d+delta*2.,6.5);
	}else{
		b=0.;
	}
	if(b>0.5){
		a=mod(a+0.7*delta*smoothstep(0.2,1.,c/4.)*min(d,1.),3.1415926*4.);
	}else{
		if(c>0.01){
			a=mod(a+0.7*delta*smoothstep(0.2,1.,c/4.)*min(d,1.),3.1415926*4.);
			c=max(c-delta/5.,0.);
			d=max(d-delta*0.75,0.);
		}
	}
	
	fragColor=vec4(a,b,c,d);
}

void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	mainImage(COLOR,floor(UV*iResolution)+0.5,iResolution);
}
