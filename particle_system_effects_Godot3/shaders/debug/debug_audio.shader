shader_type canvas_item;
render_mode blend_mix;


uniform sampler2D iChannel0 : hint_black;


void vertex() {
    
}

vec4 mi(vec2 uv)
{
    const float bands = 30.0;
    const float segs = 40.0;
    vec2 p;
    p.x = floor(uv.x*bands)/bands;
    p.y = floor(uv.y*segs)/segs;
    float fft  = texture( iChannel0, vec2(p.x,0.0) ).x;
    vec3 color = mix(vec3(0.0, 2.0, 0.0), vec3(2.0, 0.0, 0.0), sqrt(uv.y));
    float mask = (p.y < fft) ? 1.0 : 0.1;

    vec2 d = fract((uv - p) *vec2(bands, segs)) - 0.5;
    float led = (1.-smoothstep(0.35, 0.5, abs(d.x))) *
                (1.-smoothstep(0.35, 0.5, abs(d.y)));
    vec3 ledColor = led*color*mask;

    return vec4(ledColor, clamp(dot(ledColor*10.,vec3(1.)),0.,3.)/3.);
}

void fragment() {
	
	vec2 tuv=UV;
	vec4 col=mi(tuv);
	
    COLOR = vec4(col.rgb,col.a);
}
