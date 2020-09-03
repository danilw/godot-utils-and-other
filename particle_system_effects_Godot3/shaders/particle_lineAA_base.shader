shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,unshaded;

uniform sampler2D test_texture:hint_albedo; //only for compare vs other

void vertex() {
	
}

// https://iquilezles.org/www/articles/filterableprocedurals/filterableprocedurals.htm
float filteredGrid( in vec2 p, in vec2 dpdx, in vec2 dpdy )
{
    const float N = 10.0;
    vec2 w = max(abs(dpdx), abs(dpdy));
    vec2 a = p + 0.5*w;                        
    vec2 b = p - 0.5*w;           
    vec2 i = (floor(a)+min(fract(a)*N,1.0)-
              floor(b)-min(fract(b)*N,1.0))/(N*w);
    return (i.x);
}

void fragment() {
	vec2 tuv=UV;
	tuv+=-0.5;
	float scale=.25;
	tuv.x*=scale;
	tuv.x+=(0.5/10.);
	float d=0.;
	d=filteredGrid(tuv,dFdx(tuv),dFdy(tuv)); //procedural filtered
	//d=1.-step(0.05,abs(tuv.x)); //procedural, not filtered
	
	tuv=UV;
	tuv.x=(tuv.x-0.5)*scale+0.5;
	//d=texture(test_texture,tuv).a; //texture
	
	ALBEDO=vec3(0.);
	ALBEDO=d*vec3(0.0);
	ALPHA=d;
	//ALBEDO=vec3(1.);
}
