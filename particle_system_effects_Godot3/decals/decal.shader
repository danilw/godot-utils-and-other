shader_type spatial;
render_mode blend_mix, unshaded, depth_draw_never, cull_front, depth_test_disable;

// decals based on https://github.com/Mr-Slurpy/Screen-Space-Decals

uniform bool emulate_lighting=true;
uniform float brightness=0.;

uniform int iFrame=0;
uniform float iTime=0.;
uniform float ttlive=30.;
uniform sampler2D expl:hint_black;
uniform sampler2D sprites:hint_black;
uniform sampler2D material_id_viewport:hint_black;
uniform int material_id=0;
uniform float depth_step=0.001;

const float dv=0.25;
int decode_mid(float mid){
	if(mid<dv){
		return -1;
	}
	return int(mid/dv)-1;
}

varying flat mat4 model_view_matrix;

void vertex(){
	model_view_matrix = MODELVIEW_MATRIX;
}

float get_depth(float depth, in mat4 proj_mat){
	depth = depth * 2.0 - 1.0;
	float z = -proj_mat[3][2] / (depth + proj_mat[2][2]);
	z*=0.1;
	depth=1.+z;
	depth=1.-clamp(depth,0.,1.);
	return depth;
}

mat2 MD(float a){
    float s = sin( a );
    float c = cos( a );
    return mat2(vec2(c, -s), vec2(s, c));
}


void fragment(){
	//float zdepth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r * 2.0 - 1.0;
	vec4 pos = inverse(model_view_matrix) * INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r * 2.0 - 1.0, 1.0);
	
	pos.xyz /= pos.w;
	
	bool inside = all(greaterThanEqual(pos.xyz, vec3(-1.0))) && all(lessThanEqual(pos.xyz, vec3(1.0)));
	
	if(inside){
		float tile_sz=1./16.;
		int lFramec=iFrame/2;
		int lframe=min(lFramec,16*16*3-1);
		vec2 counter=vec2(float(lframe%16),float((lframe%(16*16))/16));
		int idx=((lframe%(16*16*3))/(16*16));
		vec2 tp=pos.xz;
		vec3 base_c=(1.+0.*(1.-smoothstep(0.,0.2,length(tp))))*mix(vec3(.2,01.16,0.21),vec3(.2,0.26,0.81),smoothstep(0.,1.,iTime/ttlive));
		if(lFramec>=16*16*3){
			tp*=MD(max(float(lFramec-(16*16*3-1)),0.)/(30.));
		}
		vec2 tuv=(tp * 0.5 + 0.5)*tile_sz+tile_sz*counter;
		vec4 color = texture(sprites, tuv);
		if(any(greaterThan(abs(tp),vec2(1.)))){
			color=vec4(0.0);
		}
		float d=0.;
		switch(idx){
			case 0:d=color.r;break;
			case 1:d=color.g;break;
			case 2:d=color.b;break;
		}
		
		color=vec4(base_c/max(1.-d,0.0051),d);
		color.a*=(1.-smoothstep(0.65,1.,iTime/ttlive));
		float d2=texture(expl,pos.xz*0.5+0.5).a;
		vec4 color2=vec4(vec3(1.,0.2,0.05)/max(1.-d2,0.001),d2*d2);
		color2*=(smoothstep(0.,0.1,iTime))*(1.-smoothstep(0.1,3.,iTime));
		
		//vec4 data=texelFetch(material_id_viewport,ivec2(FRAGCOORD.xy),0);
		vec4 data=textureLod(material_id_viewport,SCREEN_UV,0.);
		float depth = texelFetch(DEPTH_TEXTURE,ivec2(FRAGCOORD.xy),0).x;
		depth=get_depth(depth,PROJECTION_MATRIX);
		int mid=-1;
		if((depth+depth_step*(depth*0.5+0.5)>=data.z)&&(depth-depth_step*(depth*0.5+0.5)<=data.z)){
			mid=decode_mid(data.x*data.a);
		}
		if((mid!=material_id)&&(material_id>=0)){
			ALBEDO=vec3(0.);
			ALPHA=0.;
		}
		else{
			if(emulate_lighting){
				float lum = dot(textureLod(SCREEN_TEXTURE, SCREEN_UV, 0).rgb, vec3(0.2125, 0.7154, 0.0721));
				lum += brightness;
				lum = clamp(lum, 0.0, 1.0);
				color=vec4(color2.rgb+color.rgb*lum,max(color2.a,color.a));
				ALBEDO = color.rgb;
				ALPHA = color.a;
				ALPHA *= smoothstep(0.,0.5,pos.y*0.5+0.5)*(1.-smoothstep(0.5,1.,pos.y*0.5+0.5));
			}else{
				ALBEDO = color.rgb;
				ALPHA=color.a;
			}
		}
	}else{
		ALBEDO=vec3(0.);
		ALPHA=0.;
	}
}