shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled,vertex_lighting;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D tex_border : hint_albedo;
uniform sampler2D texture_normal : hint_normal;

uniform vec3 spherePos1;
uniform float sphereRad1;
uniform vec4 spherecol1:hint_color;

uniform vec3 spherePos2;
uniform float sphereRad2;
uniform vec4 spherecol2:hint_color;

uniform vec3 tubeStart1;
uniform vec3 tubeEnd1;
uniform float tubeRad1;
uniform vec4 tubecol1:hint_color;

uniform vec3 tubeStart2;
uniform vec3 tubeEnd2;
uniform float tubeRad2;
uniform vec4 tubecol2:hint_color;

uniform vec3 tubeStart3;
uniform vec3 tubeEnd3;
uniform float tubeRad3;
uniform vec4 tubecol3:hint_color;

varying vec2 ouv;
void vertex() {
	UV=UV-0.5;
	ouv=UV;
	UV=UV*vec2(20.,8.);
}

// using https://www.shadertoy.com/view/ldfGWs
//--------------------

float specTrowbridgeReitz( float HoN, float a, float aP )
{
	float a2 = a * a;
	float aP2 = aP * aP;
	float v=pow( HoN * HoN * ( a2 - 1.0 ) + 1.0, 2.0 );
	if (v==0.) return 0.;
	return ( a2 * aP2 ) / v;
}

float visSchlickSmithMod( float NoL, float NoV, float r )
{
	float k = pow( r * 0.5 + 0.5, 2.0 ) * 0.5;
	float l = NoL * ( 1.0 - k ) + k;
	float v = NoV * ( 1.0 - k ) + k;
	if ((v==0.)||(l==0.)) return 0.;
	return 1.0 / ( 4.0 * l * v );
}

float fresSchlickSmith( float HoV, float f0 )
{
	return f0 + ( 1.0 - f0 ) * pow( 1.0 - HoV, 5.0 );
}

float sphereLight( vec3 pos, vec3 N, vec3 V, vec3 r, float f0, float roughness, float NoV, out float NoL, 
	vec3 spherePos, float sphereRad)
{
	vec3 L				= spherePos - pos;
	vec3 centerToRay	= dot( L, r ) * r - L;
	vec3 closestPoint	= L + centerToRay * clamp( sphereRad / max(length( centerToRay ),.001), 0.0, 1.0 );
	vec3 l				= normalize( closestPoint );
	vec3 h				= normalize( V + l );
	
	NoL				= clamp( dot( N, l ), 0.0, 1.0 );
	float HoN		= clamp( dot( h, N ), 0.0, 1.0 );
	float HoV		= dot( h, V );
	
	float distL		= length( L );
	float alpha		= roughness * roughness;
	float alphaPrime	=0.;
	if(( distL * 2.0 ) + alpha!=0.) alphaPrime=clamp( sphereRad / ( distL * 2.0 ) + alpha, 0.0, 1.0 );
	
	float specD		= specTrowbridgeReitz( HoN, alpha, alphaPrime );
	float specF		= fresSchlickSmith( HoV, f0 );
	float specV		= visSchlickSmithMod( NoL, NoV, roughness );
	
	return specD * specF * specV * NoL;
}

float tubeLight( vec3 pos, vec3 N, vec3 V, vec3 r, float f0, float roughness, float NoV, out float NoL,
	vec3 tubeStart, vec3 tubeEnd, float tubeRad)
{
	vec3 L0			= tubeStart - pos;
	vec3 L1			= tubeEnd - pos;
	float distL0	= length( L0 );
	float distL1	= length( L1 );
	
	float NoL0		= dot( L0, N ) / max(( 2.0 * distL0 ),0.001);
	float NoL1		= dot( L1, N ) / max(( 2.0 * distL1 ),0.001);
	NoL				= ( 2.0 * clamp( NoL0 + NoL1, 0.0, 1.0 ) ) 
					/ max(( distL0 * distL1 + dot( L0, L1 ) + 2.0 ),0.001);
	
	vec3 Ld			= L1 - L0;
	float RoL0		= dot( r, L0 );
	float RoLd		= dot( r, Ld );
	float L0oLd 	= dot( L0, Ld );
	float distLd	= length( Ld );
	float t			= ( RoL0 * RoLd - L0oLd ) 
					/ max(( distLd * distLd - RoLd * RoLd ),0.001);
	
	vec3 closestPoint	= L0 + Ld * clamp( t, 0.0, 1.0 );
	vec3 centerToRay	= dot( closestPoint, r ) * r - closestPoint;
	closestPoint		= closestPoint + centerToRay * clamp( tubeRad / max(length( centerToRay ),0.001), 0.0, 1.0 );
	vec3 l				= normalize( closestPoint );
	vec3 h				= normalize( V + l );
	
	float HoN		= clamp( dot( h, N ), 0.0, 1.0 );
	float HoV		= dot( h, V );
	
	float distLight	= length( closestPoint );
	float alpha		= roughness * roughness;
	float alphaPrime	= 0.;
	if(( distLight * 2.0 ) + alpha!=0.) alphaPrime=clamp( tubeRad / ( distLight * 2.0 ) + alpha, 0.0, 1.0 );
	
	float specD		= specTrowbridgeReitz( HoN, alpha, alphaPrime );
	float specF		= fresSchlickSmith( HoV, f0 );
	float specV		= visSchlickSmithMod( NoL, NoV, roughness );
	
	return specD * specF * specV * NoL;
}

//--------------------

vec3 areaLights( vec3 pos, vec3 nor, vec3 rd, vec3 albedo)
{
	float roughness = .25 - clamp( 0.5 - dot( albedo, albedo ), 0.05, 0.95 );
	float f0		= 0.53;
	
	vec3 v			= -normalize( rd );
	float NoV		= clamp( dot( nor, v ), 0.0, 1.0 );
	vec3 r			= reflect( -v, nor );
	
	float NdotLSphere1;
	float specSph1	= sphereLight( pos, nor, v, r, f0, roughness, NoV, NdotLSphere1, spherePos1, sphereRad1);
	float NdotLSphere2;
	float specSph2	= sphereLight( pos, nor, v, r, f0, roughness, NoV, NdotLSphere2, spherePos2, sphereRad2);
	
	float NdotLTube1;
	float specTube1	= tubeLight( pos, nor, v, r, f0, roughness, NoV, NdotLTube1, tubeStart1, tubeEnd1, tubeRad1);
	float NdotLTube2;
	float specTube2	= tubeLight( pos, nor, v, r, f0, roughness, NoV, NdotLTube2, tubeStart2, tubeEnd2, tubeRad2);
	float NdotLTube3;
	float specTube3	= tubeLight( pos, nor, v, r, f0, roughness, NoV, NdotLTube3, tubeStart3, tubeEnd3, tubeRad3);
	
	vec3 color	= albedo * 01.5 * (NdotLSphere1*spherecol1.rgb + NdotLTube1*tubecol1.rgb+
	NdotLTube3*tubecol3.rgb + NdotLTube2*tubecol2.rgb + NdotLSphere2*spherecol2.rgb) +
	specSph1*spherecol1.rgb*3.5 + specTube1*tubecol1.rgb*2.5 + specSph2*spherecol2.rgb*3.5 + 
	specTube2*tubecol2.rgb*2.5 + specTube3*tubecol3.rgb*2.5;
	return (color);
}

void fragment() {
	vec3 rd=normalize(((CAMERA_MATRIX) * vec4(normalize(VERTEX), 0.0)).xyz);
	vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 pos=vec3(UV.x,0.,UV.y);
	
	vec2 base_uv = UV;
	float border=sqrt(texture(tex_border,ouv).r);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = vec3(0.);
	NORMALMAP = texture(texture_normal,base_uv).rgb;
	
	vec3 albedox = pow(albedo_tex.rgb , vec3(3.2) );
	vec3 normal = mix(vec3(0.0, 0.0, 1.0), NORMALMAP * vec3(2.0, -2.0, 1.0) - vec3(1.0, -1.0, 0.0), 0.35);
	
	EMISSION=clamp(areaLights(pos,(nor-nor*normal),rd,albedox),0.,5.);
	EMISSION*=pow(texture(tex_border,ouv+0.5).r,.5);

}
