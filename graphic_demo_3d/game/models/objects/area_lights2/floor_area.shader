shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled;
uniform sampler2D tx_o : hint_albedo;
uniform sampler2D tx_ox: hint_albedo;
uniform sampler2D tx_b : hint_albedo;
uniform sampler2D ltc_mat : hint_albedo;
uniform sampler2D ltc_mag : hint_albedo;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_normal : hint_normal;
uniform float iTime;

uniform float intensity = 1.5;
uniform float roughtnss:hint_range(0,1)=0.05;

uniform float light_width0 = .5;
uniform float light_height0 = .5;
uniform vec3 light_pos0 = vec3(0., 0.73, 0.);
uniform vec3 light_normal0 = vec3(0., 0., 1.);

uniform float light_width1 = .5;
uniform float light_height1 = .5;
uniform vec3 light_pos1 = vec3(0., 0.73, 0.);
uniform vec3 light_normal1 = vec3(0., 0., 1.);

uniform float light_width2 = .5;
uniform float light_height2 = .5;
uniform vec3 light_pos2 = vec3(0., 0.73, 0.);
uniform vec3 light_normal2 = vec3(0., 0., 1.);

uniform vec4 light_col:hint_color = vec4(1.0);
uniform vec4 diff_col:hint_color=vec4(1.);
uniform vec4 spec_col:hint_color=vec4(1.);

varying vec2 ouv;

void vertex() {
	ouv=UV;
	UV=(UV-0.5)*vec2(3.,15.);
}

// using https://eheitzresearch.wordpress.com/415-2/
// its code on shadertoy https://www.shadertoy.com/view/MsyXRG

const float PI = 3.1415926;

const float LUT_SCALE = (64.0 - 1.0)/64.0;
const float LUT_BIAS  = 0.5/64.0;

void init_rect_points(out vec3 points_a,out vec3 points_b,out vec3 points_c,out vec3 points_d, vec3 light_normal,
						float light_width, float light_height, vec3 light_pos)
{
    // get the orthogonal basis of polygon light
    vec3 right=normalize(cross(light_normal, vec3(0.0, 1.0, 0.0)));
    vec3 up=normalize(cross(right, light_normal));
    
    vec3 ex = light_width * right;
    vec3 ey = light_height * up;
	
	vec3 lp=light_pos+vec3(0.,0.5,0.);
    points_a = lp - ex - ey;
    points_b = lp + ex - ey;
    points_c = lp + ex + ey;
    points_d = lp - ex + ey;
}

// Linearly Transformed Cosines 

float IntegrateEdge(vec3 v1, vec3 v2)
{
    float cosTheta = dot(v1, v2);
    float theta = acos(cosTheta);    
    float res = cross(v1, v2).z * ((theta > 0.001) ? theta/sin(theta) : 1.0);

    return res;
}

void ClipQuadToHorizon(inout vec3 La, inout vec3 Lb, inout vec3 Lc, inout vec3 Ld, inout vec3 Le, out int n)
{
    // detect clipping config
    int config = 0;
    if (La.z > 0.0) config += 1;
    if (Lb.z > 0.0) config += 2;
    if (Lc.z > 0.0) config += 4;
    if (Ld.z > 0.0) config += 8;

    // clip
    n = 0;

    if (config == 0)
    {
        // clip all
    }
    else if (config == 1) // V1 clip V2 V3 V4
    {
        n = 3;
        Lb = -Lb.z * La + La.z * Lb;
        Lc = -Ld.z * La + La.z * Ld;
    }
    else if (config == 2) // V2 clip V1 V3 V4
    {
        n = 3;
        La = -La.z * Lb + Lb.z * La;
        Lc = -Lc.z * Lb + Lb.z * Lc;
    }
    else if (config == 3) // V1 V2 clip V3 V4
    {
        n = 4;
        Lc = -Lc.z * Lb + Lb.z * Lc;
        Ld = -Ld.z * La + La.z * Ld;
    }
    else if (config == 4) // V3 clip V1 V2 V4
    {
        n = 3;
        La = -Ld.z * Lc + Lc.z * Ld;
        Lb = -Lb.z * Lc + Lc.z * Lb;
    }
    else if (config == 5) // V1 V3 clip V2 V4) impossible
    {
        n = 0;
    }
    else if (config == 6) // V2 V3 clip V1 V4
    {
        n = 4;
        La = -La.z * Lb + Lb.z * La;
        Ld = -Ld.z * Lc + Lc.z * Ld;
    }
    else if (config == 7) // V1 V2 V3 clip V4
    {
        n = 5;
        Le = -Ld.z * La + La.z * Ld;
        Ld = -Ld.z * Lc + Lc.z * Ld;
    }
    else if (config == 8) // V4 clip V1 V2 V3
    {
        n = 3;
        La = -La.z * Ld + Ld.z * La;
        Lb = -Lc.z * Ld + Ld.z * Lc;
        Lc =  Ld;
    }
    else if (config == 9) // V1 V4 clip V2 V3
    {
        n = 4;
        Lb = -Lb.z * La + La.z * Lb;
        Lc = -Lc.z * Ld + Ld.z * Lc;
    }
    else if (config == 10) // V2 V4 clip V1 V3) impossible
    {
        n = 0;
    }
    else if (config == 11) // V1 V2 V4 clip V3
    {
        n = 5;
        Le = Ld;
        Ld = -Lc.z * Ld + Ld.z * Lc;
        Lc = -Lc.z * Lb + Lb.z * Lc;
    }
    else if (config == 12) // V3 V4 clip V1 V2
    {
        n = 4;
        Lb = -Lb.z * Lc + Lc.z * Lb;
        La = -La.z * Ld + Ld.z * La;
    }
    else if (config == 13) // V1 V3 V4 clip V2
    {
        n = 5;
        Le = Ld;
        Ld = Lc;
        Lc = -Lb.z * Lc + Lc.z * Lb;
        Lb = -Lb.z * La + La.z * Lb;
    }
    else if (config == 14) // V2 V3 V4 clip V1
    {
        n = 5;
        Le = -La.z * Ld + Ld.z * La;
        La = -La.z * Lb + Lb.z * La;
    }
    else if (config == 15) // V1 V2 V3 V4
    {
        n = 4;
    }
    
    if (n == 3)
        Ld = La;
    if (n == 4)
        Le = La;
}

vec3 LTC_Evaluate(vec3 N, vec3 V, vec3 P, mat3 Minv, vec3 points_a, vec3 points_b, vec3 points_c, vec3 points_d, int mat_id, bool ds, vec3 albedox)
{
    // construct orthonormal basis around N
    vec3 T1, T2;
	T1 = normalize(V - N*dot(V, N));
    T2 = cross(N, T1);

    // rotate area light in (T1, T2, N) basis
    Minv = Minv * transpose(mat3(T1, T2, N));

    // polygon (allocate 5 vertices for clipping)
    vec3 L[5];
    L[0] = Minv * (points_a - P);
    L[1] = Minv * (points_b - P);
    L[2] = Minv * (points_c - P);
    L[3] = Minv * (points_d - P);
	L[4]=vec3(0.);

    int n=0;
    // The integration is assumed on the upper hemisphere
    // so we need to clip the frustum, the clipping will add 
    // at most 1 edge, that's why L is declared 5 elements.
    ClipQuadToHorizon(L[0],L[1],L[2],L[3],L[4],n);
    
    if (n == 0)
        return vec3(0, 0, 0);

    // project onto sphere
    vec3 PL[5];
	PL[0] = normalize(L[0]);
    PL[1] = normalize(L[1]);
    PL[2] = normalize(L[2]);
    PL[3] = normalize(L[3]);
    PL[4] = normalize(L[4]);

    // integrate for every edge.
    float sum = 0.0;

    sum += IntegrateEdge(PL[0], PL[1]);
    sum += IntegrateEdge(PL[1], PL[2]);
    sum += IntegrateEdge(PL[2], PL[3]);
    if (n >= 4)
        sum += IntegrateEdge(PL[3], PL[4]);
    if (n == 5)
        sum += IntegrateEdge(PL[4], PL[0]);

    sum =  max(0.0, sum);
	vec3 Lo_i = vec3(0.);
	if((mat_id==2)&&(ds)){
	    vec3 e1 = normalize(L[0] - L[1]);
	    vec3 e2 = normalize(L[2] - L[1]);
	    vec3 N2 = cross(e1, e2);
	    vec3 V2 = N2 * dot(L[1], N2);
	    vec2 Tlight_shape = max(vec2(length(L[0] - L[1]), length(L[2] - L[1])),vec2(0.01));
	    V2 = V2 - L[1];
	    float b = max(e1.y*e2.x - e1.x*e2.y ,.01);
		vec2 pLight = vec2((V2.y*e2.x - V2.x*e2.y)/b, (V2.x*e1.y - V2.y*e1.x)/b);
	   	pLight /= Tlight_shape;
		pLight.y=1.-pLight.y;
	    
	    vec3 ref_col = vec3(0.);
		if(all(lessThanEqual(abs(pLight-0.5),vec2(0.495)))){
			//pLight -= .5;
		    //pLight *=vec2(0.5,2.)*0.4;
		    //pLight += .5;
			vec2 po=pLight;
			pLight.y+=fract(iTime*0.15);
			pLight=fract(pLight);
			vec4 txx1 = sqrt(textureLod(tx_o, pLight,4.));
			vec4 txx2 = textureLod(tx_ox,po,4.);
			ref_col=mix(txx1.rgb*3.,(txx2.rgb)*3.,txx2.r);
		}
	
	    Lo_i = vec3(sum) * ref_col*albedox+vec3(sum)*0.25*albedox;
	}
	else {
		Lo_i = vec3(sum)*albedox;
	}
    return Lo_i;
}

    
/////////////////////////////////////////////

void LTC_shading(float roughness, 
                 vec3 N, 
                 vec3 V, 
                 vec3 pos, 
                 vec3 points_a, vec3 points_b, vec3 points_c, vec3 points_d, 
                 vec3 m_spec, 
                 vec3 m_diff, 
                 inout vec3 col,
                 int mat_id,
                 vec3 albedox)
{
    
	
	float theta = acos(dot(N, V));
	vec2 uv = vec2(roughness, theta/(0.5*PI));
	uv = uv*LUT_SCALE + LUT_BIAS;
	
	vec4 params = texture(ltc_mat, uv);

    mat3 Minv = mat3(
        vec3(  1,        0,      params.y),
        vec3(  0,     params.z,   0),
        vec3(params.w,   0,      params.x)
    );

    vec3 spec = LTC_Evaluate(N, V, pos, Minv, points_a, points_b, points_c, points_d, mat_id, true, albedox)*m_spec;
	
	spec *= texture(ltc_mag, uv).r;

    vec3 diff = LTC_Evaluate(N, V, pos, mat3(1), points_a, points_b, points_c, points_d, mat_id, false, albedox)*m_diff; 
	
    col  = light_col.rgb*(m_spec*spec + m_diff*diff)*intensity;//*sha; SHADOW
    col /= 2.0*PI;
}


const vec3 col_o=vec3(0.79,0.43,1.);

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX) * vec4(normalize(-VERTEX), 0.0)).xyz);
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	vec3 pos=vec3(UV.x,0.,UV.y);
	vec3 ref = reflect(rd,nor);
	vec2 tuv = UV;
	METALLIC = 0.0;
	ROUGHNESS = roughtnss;
	SPECULAR = 0.5;
	
	vec3 col=vec3(0);
	
	vec2 p = tuv;
	
	NORMALMAP = texture(texture_normal,UV).rgb;
	
	vec3 albedox = pow( texture( texture_albedo, UV ).xyz, vec3(2.) )+0.15;
	vec3 normal = mix(vec3(0.0, 0.0, 1.0), NORMALMAP * vec3(2.0, -2.0, 1.0) - vec3(1.0, -1.0, 0.0), 0.35);
	
	vec3 points_a, points_b, points_c, points_d;
	vec3 retc=vec3(0.);
	init_rect_points(points_a, points_b, points_c, points_d, light_normal0, light_width0, light_height0, light_pos0);
	float tr=ROUGHNESS+albedox.r*albedox.r*4.;
	LTC_shading(tr, (nor-nor*normal*5.), rd, pos, points_a, points_b, points_c, points_d, diff_col.rgb, spec_col.rgb, retc, 2, albedox);
	col+=retc*1.5;
	retc=vec3(0.);
	init_rect_points(points_a, points_b, points_c, points_d, light_normal1, light_width1, light_height1, light_pos1);
	LTC_shading(ROUGHNESS, (nor-nor*normal*5.), rd, pos, points_a, points_b, points_c, points_d, diff_col.rgb, spec_col.rgb, retc, 1, albedox);
	col+=retc*1.5;
	retc=vec3(0.);
	init_rect_points(points_a, points_b, points_c, points_d, light_normal2, light_width2, light_height2, light_pos2);
	LTC_shading(ROUGHNESS, (nor-nor*normal*5.), rd, pos, points_a, points_b, points_c, points_d, diff_col.rgb, spec_col.rgb, retc, 1, albedox);
	col+=retc*1.5;
	
	col*=min(texture(tx_b,1.-ouv.yx).r*5.,1.);
	ALBEDO=col;
	EMISSION=col;
	
}
