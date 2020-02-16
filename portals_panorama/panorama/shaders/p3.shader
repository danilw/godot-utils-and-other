shader_type spatial;
render_mode blend_mix,depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec3 dir_angle;
uniform float iTime;

//https://www.shadertoy.com/view/WtBXWw
//Based on Naty Hoffmann and Arcot J. Preetham. Rendering out-door light scattering in real time.
//http://renderwonk.com/publications/gdm-2002/GDM_August_2002.pdf

vec3 ACESFilm( vec3 x )
{
    float tA = 2.51;
    float tB = 0.03;
    float tC = 2.43;
    float tD = 0.59;
    float tE = 0.14;
    return clamp((x*(tA*x+tB))/(x*(tC*x+tD)+tE),0.0,1.0);
}

vec3 sky( in vec3 rd) {
    
    float Gamma=2.2;
	float Rayleigh=1.;
	float Mie=1.;
	float  RayleighAtt=1.;
	float MieAtt=1.2;
    //float g = -0.84;
    //float g = -0.97;
    float g = -0.97;
    vec3 ds = -normalize(dir_angle); //sun 

    vec3 _betaR = vec3(0.0195,0.11,0.294); 
    vec3 _betaM = vec3(0.04);
    vec3 c3=vec3(0.01,0.05,0.15); // bot color

    vec3 col = vec3(0.);
    vec3 ord=rd;

    if (rd.y < 0.) {
        rd.y = -rd.y;
        rd = normalize(rd);
    }

    float sR = RayleighAtt / rd.y ;
    float sM = MieAtt / rd.y ;
    float cosine = clamp(dot(rd,ds),0.0,1.0);
    vec3 extinction = exp(-(_betaR * sR + _betaM * sM));
    float g2 = g * g;
    float fcos2 = cosine * cosine;
    if(ord.y<0.)cosine=clamp(dot(ord,ds),0.0,1.0);
    float miePhase = Mie * pow(1. + g2 + 2. * g * cosine, -1.5) * (1. - g2) / (2. + g2);
    float rayleighPhase = Rayleigh;
    vec3 inScatter = (1. + fcos2) * vec3(rayleighPhase + _betaM / _betaR * miePhase);

    col = inScatter*(1.0-extinction); // *vec3(1.6,1.4,1.0)

    // sun
    col += 0.47*vec3(1.6,1.4,1.0)*pow( cosine, 350.0 ) * extinction;
    // sun haze
    col += 0.4*vec3(0.8,0.9,1.0)*pow( cosine, 2.0 )* extinction;
    col = ACESFilm(col);
    col = pow(col, vec3(Gamma));
    
    float hor=1.;
    if(ord.y<0.)
    hor=1.-max(-ord.y,0.);
    float hor_power=pow(hor,3.0); //horizont, remove if not needed
    return mix(c3,clamp(col,vec3(0.),vec3(1.)),hor_power);
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	rd=-rd;
	vec3 sky_col=sky(rd);
	ALBEDO=sky_col;
	//ALBEDO=ALBEDO*ALBEDO; //to use in Godot GLES3 add this color correction
	
}
