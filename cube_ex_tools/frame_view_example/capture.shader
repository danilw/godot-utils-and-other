shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;

// Created by Danil (2020+) https://github.com/danilw
// The MIT License

uniform sampler2D texture_capture : hint_albedo;
uniform vec4 color:hint_color;
uniform float shape_size=0.1;

uniform float iTime;

// set next values
const float sec_to_record=8.;
const float box_size=20.;

const vec2 image_size=vec2(702.,351.); // capture image size, GLES2 does not have textureSize function in shaders
const int default_fps=60;


// this shader only for 16x16 (256) particles
// this shader only for GLES2, for GLES3 beter rewrite this logic to use real particles

int get_index(in vec2 uv){
    return int(uv.x*16.)*16+int(mod(floor(uv.y*16.),16.));
}

vec2 get_index_v2(in vec2 uv){
  return floor(uv*16.);
 }

mat3 rotx(float a){float s = sin(a);float c = cos(a);return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c));  }
mat3 roty(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));}
mat3 rotz(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0 ));}

varying flat float frame_fade; // fade on end of animation-time
varying flat float dist_fade; //fade when element close to box border

void vertex() {
  float total_frames=float(default_fps)*sec_to_record;
  
//  int iFrame=int(mod((TIME*60.)*1.,total_frames));
  int iFrame=int(clamp((iTime*60.),0.,total_frames));
  frame_fade=1.-smoothstep(0.85,1.,float(iFrame)/total_frames);
  int idx=get_index(UV);
  int tidx=idx+256*iFrame;
  ivec2 idtx=ivec2(int(mod(float(tidx*2),image_size.x)),(tidx*2)/int(image_size.x));
  vec3 pos1=textureLod(texture_capture,(vec2(idtx)+0.5)/image_size,0.).xyz;
  idtx=ivec2(int(mod(float(tidx*2+1),image_size.x)),(tidx*2+1)/int(image_size.x));
  vec3 pos2=textureLod(texture_capture,(vec2(idtx)+0.5)/image_size,0.).xyz;
  
  vec3 rpos1=vec3(pos1.x,pos1.z,pos2.y);
  vec3 rpos2=vec3(pos1.y,pos2.x,pos2.z);
  
  vec3 pos=vec3(ivec3(rpos2*65280.)+ivec3(rpos1*256.))/65536.;
  pos=pos+vec3(-0.5,0.,-0.5);
  dist_fade=1.-smoothstep(0.85,1.,2.*max(abs(pos.x),abs(pos.z)));
  if(any(greaterThan(abs(pos.xz),vec2(0.495)))){
    pos=vec3(-9999.+float(idx)/256.);
  }
  vec3 dirx=pos*box_size*(1./(shape_size*4.));
  
  mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),vec4(dirx,1.));
  VERTEX*=rotx(3.141516926*0.5);
  VERTEX=(mat_world*vec4(VERTEX,1.)).xyz;
  VERTEX+=dirx;
  VERTEX*=shape_size*2.;
}


void fragment() {
  ALBEDO=color.rgb*frame_fade*dist_fade;
}
