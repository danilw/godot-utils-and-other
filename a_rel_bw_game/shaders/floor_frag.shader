shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,unshaded;
uniform float ppos;

vec4 mcol( in vec2 uv , float iTime)
{
	float speed = 10.0;
	float thickness = 0.25;
	float spread = 30.0;
	float direction = 1.0;
	vec3 ret_col = vec3(0.0);
	float resx=800.;
    vec2 coord = uv*resx;
    vec2 center = vec2(resx/2.);
	float dist = length(center - coord);
    float distToEdge = 01.0 - dist / (resx / 2.0);
	float x = center.x - coord.x;
	float y = center.y - coord.y;

	float r = -(x * x + y * y);
    
    float circles = cos((r / (spread * 150.0)  + (iTime * direction) * speed));
        circles *= thickness * 10.0;

	float c = smoothstep(1.0 - thickness, 1.0, circles);
    
    c *= distToEdge;    
	c=clamp(c,0.,1.);
	vec3 col = 10.*vec3(2.0, .50, 1.0);
    ret_col = col*c;
	
	return vec4(ret_col, c*(ppos));
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(VERTEX),0.0)).xyz));
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float v = 1.0/( 2. * ( 1. + rd.z ) );
	vec2 xy = vec2(rd.y * v, rd.x * v); 
	vec4 tc=mcol(UV,TIME);
	ALBEDO = tc.rgb;
	
	//float intensity = pow(0.122 + dot(NORMAL, normalize(VIEW)), 010.85);
	ALPHA=tc.a;
	//ALPHA=1.;

}