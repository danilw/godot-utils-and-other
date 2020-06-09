shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_disabled;

uniform sampler2D floor_img;

void vertex() {
	
}

//from https://iquilezles.org/www/articles/filterableprocedurals/filterableprocedurals.htm

float filteredSquares( in vec2 p, in vec2 dpdx, in vec2 dpdy )
{
    const float N = 3.0;
    vec2 w = max(abs(dpdx), abs(dpdy));
    vec2 a = p + 0.5*w;                        
    vec2 b = p - 0.5*w;           
    vec2 i = (floor(a)+min(fract(a)*N,1.0)-
              floor(b)-min(fract(b)*N,1.0))/(N*w);
    return 1.0-i.x*i.y;
}

float filteredCrosses( in vec2 p, in vec2 dpdx, in vec2 dpdy )
{
    const float N = 3.0;
    vec2 w = max(abs(dpdx), abs(dpdy));
    vec2 a = p + 0.5*w;                        
    vec2 b = p - 0.5*w;           
    vec2 i = (floor(a)+min(fract(a)*N,1.0)-
              floor(b)-min(fract(b)*N,1.0))/(N*w);
    return 1.0-i.x-i.y+2.0*i.x*i.y;
}

const vec3 co=vec3(1.,0.54,0.18);

void light() {
	vec3 col=texture(floor_img,UV).rgb;
	if(col.r>0.001){
		float dif = clamp(dot(NORMAL,LIGHT), 0.0, 1.0);
		vec3 hal = normalize(VIEW+LIGHT);
		float spe = pow(clamp(dot(hal, NORMAL), 0.0, 1.0), 32.0);
		vec3 ta=ATTENUATION;
		vec2 tuv=UV*vec2(15.,10.)*50.;
		vec2 ddx = dFdx(tuv); 
		vec2 ddy = dFdy(tuv);
		float tx=filteredSquares(tuv, ddx, ddy);
		float tx2=filteredCrosses(tuv, ddx, ddy);
	    DIFFUSE_LIGHT = dif*co*spe*4.* ta*col;
		DIFFUSE_LIGHT = clamp(DIFFUSE_LIGHT,0.,1.);
		SPECULAR_LIGHT = mix(ta,vec3(0.)+DIFFUSE_LIGHT,clamp(dif*spe*5.,0.,1.))*tx+0.5*((1.-tx2)*(clamp(1.-ta*5.,0.,1.)));
		SPECULAR_LIGHT = clamp(SPECULAR_LIGHT*col,0.,1.);
	}
	else{
		DIFFUSE_LIGHT=vec3(0.);
		SPECULAR_LIGHT=vec3(0.);
	}
}


void fragment() {
	vec3 col=texture(floor_img,UV).rgb;
	ALBEDO = col;
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.5;
}
