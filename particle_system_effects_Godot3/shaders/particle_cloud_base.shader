shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_schlick_ggx,shadows_disabled; //ambient_light_disabled

uniform bool use_occ=false;
uniform bool cell_shading=false;
uniform bool fix_perspective=false;
uniform bool use_light_color=true;

uniform vec4 object_color : hint_color = vec4(0.5,0.5,0.5,1.0);
uniform vec4 base_light_color : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 shade_color : hint_color = vec4(0.05,0.05,0.05,1.);

uniform float shade_threshold : hint_range(-1.0, 1.0, 0.001) = 0.1;
uniform float shade_softness : hint_range(0.0, 1.0, 0.001) = 0.02;

varying vec3 spos;
varying vec3 roc;
varying float sp_size;

// fix black color
// t2=max(t2,0.001)

void vertex() {
    //MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
	
	mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
	float ts=1.;
	
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
	spos=mat_world[3].xyz;
	sp_size=2./max(length(WORLD_MATRIX[0].xyz),0.0001);
	roc=CAMERA_MATRIX[3].xyz*sp_size;
	if(fix_perspective)
		//VERTEX*=clamp(length(spos-CAMERA_MATRIX[3].xyz)/2.,0.,1.); //correct proportion fix on zoom
		VERTEX*=clamp(length(spos-CAMERA_MATRIX[3].xyz)/(2./sp_size),0.,1.); //not correct proportion fix on zoom
}

float cell_shade(vec3 nor, vec3 light)
{
	float NdotL = dot(nor, light);
	float is_lit = step(shade_threshold, NdotL);
	float shade_value = smoothstep(shade_threshold - shade_softness ,shade_threshold + shade_softness, NdotL);
	//diffuse = mix(shade, base, shade_value);
	return shade_value;
}

// The MIT License
// Copyright © 2014 Inigo Quilez
// https://iquilezles.org/www/articles/intersectors/intersectors.htm
float sphIntersect( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

vec3 sphNormal( in vec3 pos, in vec4 sph )
{
    return normalize(pos-sph.xyz);
}

vec4 sph_img( vec3 rd , vec3 lght, vec3 ro, vec3 sp, float sp_sz,vec3 bcol)
{
    vec4 sph = vec4( sp, sp_sz);
    vec3 lig=lght;
    vec3 col = vec3(0.0);

    float tmin = 1e10;
    vec3 nor=vec3(0.);
    float occ = 1.0;
	float a=0.;

    float t2 = sphIntersect( ro, rd, sph );
	t2=max(t2,0.001); //to fix black color
    if( t2>0.0 && t2<tmin )
    {
        tmin = t2;
        vec3 pos = ro + t2*rd;
        nor = sphNormal( pos, sph );
        occ = 0.5 + 0.5*nor.y;
	}

    if( tmin<1000.0 )
    {
        vec3 pos = ro + tmin*rd;
        
		col = vec3(1.0);
		a=1.;
		float shade_value=0.;
        if(!cell_shading)
		shade_value = clamp( dot(nor,lig), 0.0, 1.0 ); //base shadow
		else
		shade_value=cell_shade(nor,lig); //cell
		if(use_occ)shade_value+=0.05*occ;
		col = mix(shade_color.rgb, bcol, shade_value);
	    //col *= exp( -0.05*tmin );
    }
	//col=clamp(col,0.,1.);
    col = sqrt(col);
    return vec4(col, a );
}

void light(){
	vec3 rd=normalize(((CAMERA_MATRIX) * vec4(normalize(-VIEW), 0.0)).xyz);
	//DIFFUSE_LIGHT=vec3(0.);
	//SPECULAR_LIGHT=vec3(0.);
	
	vec3 lgt=normalize(((CAMERA_MATRIX) * vec4(normalize(LIGHT), 0.0)).xyz);
	//proportion fix on zoom
	vec4 col=vec4(0.);
	vec3 lc=base_light_color.rgb;
	if(use_light_color){
		lc=LIGHT_COLOR;
	}
	if(fix_perspective)
		//correct
		//col=sph_img(normalize(rd),normalize( lgt ), roc,spos*sp_size, 1.-0.999*(1.-min(length(spos-CAMERA_MATRIX[3].xyz)/2.,1.)),lc);
		//not correct
		col=sph_img(normalize(rd),normalize( lgt ), roc,spos*sp_size, 1.-0.999*(1.-min(length(spos-CAMERA_MATRIX[3].xyz)/(2./sp_size),1.)),lc);
	else
		col=sph_img(normalize(rd),normalize( lgt ), roc,spos*sp_size, 1.,lc); //no fix
	SPECULAR_LIGHT+=col.rgb*ATTENUATION*ALBEDO;
	DIFFUSE_LIGHT+=col.rgb*ATTENUATION*ALBEDO;
	//ALPHA=col.w;
}

void fragment() {
	ALBEDO=object_color.rgb;
	METALLIC = 0.;
	ROUGHNESS = 0.9;
	SPECULAR = 0.5;
	
}
