shader_type spatial;
render_mode blend_mix,depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec3 dir_angle;
uniform sampler2D iChannel0;
uniform float iTime;

//credits https://www.shadertoy.com/view/Msdfz8

vec3 Cloud(vec3 bgCol,vec3 rd,vec3 cloudCol,float spd)
{
    mat2 m2 = mat2(vec2(0.60, -0.80), vec2(0.80, 0.60));
    vec3 col = bgCol;
    float t = iTime * 0.15* spd;
    vec2 sc =rd.xz*((3.)*40000.0)/max(rd.y,0.001);
    vec2 p = 0.00002*sc;
    float f = 0.0;
  	float s = 0.5;
  	float sum =0.;
  	for(int i=0;i<5;i++){
    	p += t;t *=1.5;
    	f += s*textureLod( iChannel0, p/256.0, 0.0).x; p = m2*p*2.02;
    	sum+= s;s*=0.6;
  	}
    float val = f/sum; 
    col = mix( col, cloudCol, 0.5*smoothstep(0.5,0.8,val) );
    return col;
}

// https://www.shadertoy.com/view/lt2SR1

vec3 skyColor( in vec3 rd, vec3 c1, vec3 c2)
{
    vec3 sundir = normalize( -dir_angle );
    float yd = min(rd.y, 0.);
    rd.y = max(rd.y, 0.);
    vec3 col = vec3(0.);
    col += vec3(.4, .84 - exp( -rd.y*20. )*.3, .74- exp( -rd.y*20. )*.3) * exp(-rd.y*9.); //horizont color
    col += c1 * (1. - exp(-rd.y*8.) ) * exp(-rd.y*.9) ;
    col = mix(col*1.2, vec3(.3),  1.-exp(yd*100.));
    col += c2 * pow( max(dot(rd,sundir),0.), 20. ) * .6;
    col += pow(max(dot(rd, sundir),0.), 150.0) *.15;
    return col;
}

vec3 sky(vec3 rd) {
	vec3 c1=vec3(.3, .5, .76); // sky color
	vec3 c2=vec3(1.3, 1.18, 1.35); // sun col
	vec3 ch=skyColor(rd,c1,c2);
    vec3 col=vec3(0.);
	if(rd.y>0.)
	col=Cloud(ch,rd,vec3(1.0,0.95,1.0),1.);
    col = mix(col, 0.68*ch, pow( 1.0-max(rd.y,0.0), 16.0));
    col = mix(col, ch, pow(1.0 - max(abs(rd.y)-0.025, 0.0), 4.0));
	return col;
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	rd=-rd;
	vec3 sky_col=sky(rd);
	ALBEDO=sky_col;
	//ALBEDO=ALBEDO*ALBEDO; //to use in Godot GLES3 add this color correction
	
}
