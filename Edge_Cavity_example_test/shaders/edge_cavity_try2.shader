// THIS SHADER MUST BE APPLIED TO A QUAD (MeshInstance) WITH A SIZE OF (2, 2)
// add MeshInstance-Quad to your Camera and copy paste this shader to quad material - shader material
// and on Quad set Center_offset z to -1 
// AND on Material-Render Priority set 127

// WARNING - THIS SHADER IS JUST EXPERIMENT. this MAY BE VERY WRONG/BAD
// look image res://depth_normal_comparison.png real normal vs depth normals (used Improved normals, same quality as from buffer)

// modified 2022, by Danil:
// added method normal-edge mothod
// added Cavity-like style of edge, look below "Cavity formula" comment

// Improving quality of edge detection:
// Only way to have better quality of edges - rendeer your scene on 2x resolution of Screen resolution.

shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,unshaded;

uniform int outline_mode : hint_range(1, 2, 1) = 1;
uniform float cav_off_x = 1.;
uniform float cav_off_y = 1.;
uniform float cav_val = .1;

uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_bias : hint_range(0, 1) = 1;

uniform bool display_edge_only = false;
uniform bool display_edge_local = false;
uniform bool display_cavity = false;
uniform bool display_normal = false;
uniform bool cav_edges_st = false;


// normal texture can be filtered with MSAA
uniform sampler2D norm_texture;
uniform bool use_normal_texture=false; //set to true if you want use normal texture from its own buffer


varying flat mat4 model_view_matrix;
void vertex() {
  POSITION = vec4(VERTEX, 1.0);
  model_view_matrix = MODELVIEW_MATRIX;
}

float get_depth(vec2 suv, sampler2D detpth_tx, mat4 iprm){
  //float depth = texelFetch(sam,fc,0).x;
  float depth = texture(detpth_tx, suv).x;
  vec3 ndc = vec3(suv, depth) * 2.0 - 1.0;
  vec4 view = iprm * vec4(ndc, 1.0);
  view.xyz /= (view.w+0.000001*(1.-abs(sign(view.w))));
  float linear_depth = -view.z;
  //vec4 world = CAMERA_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  //vec3 world_position = world.xyz / world.w;
  return linear_depth;
}


vec3 getPos(float depth, mat4 mvm, mat4 ipm, vec2 suv, mat4 wm, mat4 icm){
  vec4 pos = inverse(mvm) * ipm * vec4((suv * 2.0 - 1.0), depth * 2.0 - 1.0, 1.0);
  pos.xyz /= (pos.w+0.0001*(1.-abs(sign(pos.w))));
  return (pos*icm).xyz+wm[3].xyz;
}

// improved https://www.shadertoy.com/view/fsVczR
vec3 computeNormalImproved( sampler2D depth_tx, mat4 mvm, mat4 ipm, vec2 suv, mat4 wm, mat4 icm, vec2 iResolution)
{
    vec2 e = vec2(1./iResolution);
    float c0 = texture(depth_tx,suv           ).r;
    float l2 = texture(depth_tx,suv-vec2(2,0)*e).r;
    float l1 = texture(depth_tx,suv-vec2(1,0)*e).r;
    float r1 = texture(depth_tx,suv+vec2(1,0)*e).r;
    float r2 = texture(depth_tx,suv+vec2(2,0)*e).r;
    float b2 = texture(depth_tx,suv-vec2(0,2)*e).r;
    float b1 = texture(depth_tx,suv-vec2(0,1)*e).r;
    float t1 = texture(depth_tx,suv+vec2(0,1)*e).r;
    float t2 = texture(depth_tx,suv+vec2(0,2)*e).r;
    
    float dl = abs(l1*l2/(2.0*l2-l1)-c0);
    float dr = abs(r1*r2/(2.0*r2-r1)-c0);
    float db = abs(b1*b2/(2.0*b2-b1)-c0);
    float dt = abs(t1*t2/(2.0*t2-t1)-c0);
    
    vec3 ce = getPos(c0, mvm, ipm, suv, wm, icm);

    vec3 dpdx = (dl<dr) ?  ce-getPos(l1, mvm, ipm,suv-vec2(1,0)*e, wm, icm) : 
                          -ce+getPos(r1, mvm, ipm,suv+vec2(1,0)*e, wm, icm) ;
    vec3 dpdy = (db<dt) ?  ce-getPos(b1, mvm, ipm,suv-vec2(0,1)*e, wm, icm) : 
                          -ce+getPos(t1, mvm, ipm,suv+vec2(0,1)*e, wm, icm) ;

    return normalize(cross(dpdx,dpdy));
}

vec3 SampleNormal(sampler2D sam, mat4 mvm, mat4 ipm, vec2 suv, mat4 wm, mat4 icm, vec2 iResolution)
{
    if(use_normal_texture)return texture(norm_texture,suv).xyz;
    else return computeNormalImproved( sam, mvm, ipm, suv, wm, icm, iResolution);
}



// this edge methods require use Normal texture also
// Godot does not provide Normal texture, so you have to build yourself
// using Normal texture allow to build edge "cheaper"(less texture reads) (quality from improved depth normals is better)

// (remember to NOT use it with Transparent Background Viewport, or when TrBg used remember to set Sky sphere around(look Normal Viewport))

float CheckDiff(vec4 _centerNormalDepth,vec4 _otherNormalDepth) {
  float _DepthDiffCoeff = 5.;
  float _NormalDiffCoeff = 1.;
    float depth_diff = abs(_centerNormalDepth.w - _otherNormalDepth.w);
    vec3 normal_diff = abs(_centerNormalDepth.xyz - _otherNormalDepth.xyz);
    return 
        (float(depth_diff > _DepthDiffCoeff))
        +
        float(dot(normal_diff,normal_diff))*_NormalDiffCoeff;
}

vec2 FastEdge(vec2 uv, vec2 iResolution, sampler2D detpth_tx, mat4 prm, mat4 ipm, mat4 wm, mat4 icm) {
  vec3 e = vec3(1./iResolution, 0.);
  float d = get_depth(uv,detpth_tx,prm);
  vec4 Center_P = vec4(SampleNormal(detpth_tx ,model_view_matrix, ipm, uv, wm, icm,iResolution),0.);
  Center_P.w = d;
  d = get_depth(uv + vec2(e.x,e.y),detpth_tx,prm);
  vec4 LD = vec4(SampleNormal(detpth_tx ,model_view_matrix, ipm, uv + vec2(e.x,e.y), wm, icm,iResolution),0.);
  LD.w = d;
  d = get_depth(uv + vec2(e.x,-e.y),detpth_tx,prm);
  vec4 RD = vec4(SampleNormal(detpth_tx ,model_view_matrix, ipm, uv + vec2(e.x, -e.y), wm, icm,iResolution),0.);
  RD.w = d;

  float Edge = 0.;
  Edge += CheckDiff(Center_P,LD);
  Edge += CheckDiff(Center_P,RD);
  
  float td = Center_P.w;
  return vec2(smoothstep(.0, 0.001+outline_bias, Edge),td);
}


// ------------------
// cavity edges that whiter when face camera

float CurvatureSoftClamp(float curvature, float control)
{
    if (curvature < 0.5 / control)
    {
        return curvature * (1.0 - curvature * control);
    }
    return 0.25 / control;
}

void Curvature(sampler2D sam, mat4 mvm, mat4 ipm, vec2 suv, mat4 wm, mat4 icm, vec2 iResolution, out float curvature)
{
    curvature = 0.0;
    vec3 offset = vec3(cav_off_x,cav_off_y,0.) * 1./iResolution.y;

    float normal_up = SampleNormal(sam, mvm, ipm, suv + offset.zy, wm, icm, iResolution).g;
    float normal_down = SampleNormal(sam, mvm, ipm, suv - offset.zy, wm, icm, iResolution).g;
    float normal_right = SampleNormal(sam, mvm, ipm, suv + offset.xz, wm, icm, iResolution).r;
    float normal_left = SampleNormal(sam, mvm, ipm, suv - offset.xz, wm, icm, iResolution).r;

    float normal_diff = (normal_up - normal_down) + (normal_right - normal_left);

    if (normal_diff >= 0.0)
    {
        curvature = 2.0 * CurvatureSoftClamp(normal_diff, cav_val);   
    }
    else
    {
        curvature = -2.0 * CurvatureSoftClamp(-normal_diff, cav_val);
    }
}

//-----------------



void fragment() {
  ALBEDO = outline_color.rgb;
  ALPHA=0.;
  
if (outline_mode == 1) {
    vec2 tr=FastEdge(SCREEN_UV,VIEWPORT_SIZE,DEPTH_TEXTURE,PROJECTION_MATRIX, INV_PROJECTION_MATRIX,WORLD_MATRIX,INV_CAMERA_MATRIX);
    ALPHA = tr.x;
  }else if (outline_mode == 2) {
    // default edge method
    vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 1));
    float px = 0.5/screen_size.x;
    float py = 0.5/screen_size.y;
    float d = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    float du = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, py)).x;
    float dd = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, -py)).x;
    float dr = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, 0.0)).x;
    float dl = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, 0.0)).x;
    float dq = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, py)).x;
    float de = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, py)).x;
    float dz = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, -py)).x;
    float dc = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, -py)).x;
    
    ALPHA = 0.0 + abs(abs(abs(d)-abs(du)) - abs(abs(d)-abs(dd))) + abs(abs(abs(d)-abs(dl)) - abs(abs(d)-abs(dr))) + abs(abs(abs(d)-abs(dq)) - abs(abs(d)-abs(dc))) + abs(abs(abs(d)-abs(dz)) - abs(abs(d)-abs(de)));

    ALPHA *= 50000.0;
  }
  
  ALPHA=clamp(ALPHA,0.,1.);
  
  if(display_edge_only||display_edge_local){
    if(display_edge_local&&(!display_edge_only))
    {
      float curvature;
      Curvature(DEPTH_TEXTURE, model_view_matrix, INV_PROJECTION_MATRIX, SCREEN_UV, WORLD_MATRIX, INV_CAMERA_MATRIX, VIEWPORT_SIZE.xy, curvature);
      ALBEDO=clamp( (1.0 + ALBEDO*ALPHA) * (1.0 + ALBEDO*curvature), 0.0, 4.0)/4.;
    }
    else{
      if(display_cavity){
        float curvature;
        Curvature(DEPTH_TEXTURE, model_view_matrix, INV_PROJECTION_MATRIX, SCREEN_UV, WORLD_MATRIX, INV_CAMERA_MATRIX, VIEWPORT_SIZE.xy, curvature);
        if(cav_edges_st){if(curvature>0.)curvature*=ALPHA;}
        ALBEDO=vec3(ALPHA,curvature,0.);
      }else
      ALBEDO=vec3(1.-ALPHA);
    }
    ALPHA=1.;
  }else {
    if(display_cavity){
      vec3 scr_col=texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
      
      float curvature;
      Curvature(DEPTH_TEXTURE, model_view_matrix, INV_PROJECTION_MATRIX, SCREEN_UV, WORLD_MATRIX, INV_CAMERA_MATRIX, VIEWPORT_SIZE.xy, curvature);
      if(cav_edges_st){if(curvature>0.)curvature*=ALPHA;}
      float cav_edge = max(ALPHA,abs(curvature)/2.);
      ALBEDO=clamp( (1.0 + ALBEDO*ALPHA) * (1.0 + ALBEDO*curvature), 0.0, 4.0)/4.;
      ALPHA = cav_edge*outline_color.a;
     }else ALPHA *= outline_color.a;
  }
  if(display_normal){
    ALBEDO=SampleNormal(DEPTH_TEXTURE, model_view_matrix, INV_PROJECTION_MATRIX, SCREEN_UV, WORLD_MATRIX, INV_CAMERA_MATRIX, VIEWPORT_SIZE.xy);
    ALPHA=1.;
  }
    METALLIC = 0.001;
    ROUGHNESS = 0.999;
    SPECULAR = 0.5;

}
