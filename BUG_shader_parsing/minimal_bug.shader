shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley,
    specular_schlick_ggx, unshaded;

// minimal shader for bug https://github.com/godotengine/godot/issues/43055

uniform float time; // >0

varying vec2 fc[4];

void vertex(){
  fc[0]=vec2(0.);
  fc[1]=vec2(0.);
  fc[2]=vec2(0.);
  fc[3]=vec2(0.);
}

void fragment ()
{
  float tval=0.;
  //tval=min(time,0.); // fix - uncomment this also fix, this tval is 0 always
  
  vec2 m_uv1[4];
  m_uv1[0]=fc[0]+tval;
  m_uv1[1]=fc[1]+tval;
  m_uv1[2]=fc[2]+tval;
  m_uv1[3]=fc[3]+tval;
  
  float d=0.0;
  ALBEDO = vec3(0.);
  
  for (int i = 0; i < 8; i++) {
    int tx=int(min(time,0.)); // fix - moving this out of loop fix crash
    if ((tx==0)&&(i<4)) {
      d = m_uv1[uint(i)].x;
      return;
    } else {
      d = m_uv1[uint(i - 4)].x; // crash
      // d = m_uv1[uint(max((i - 4),0))].x; // fix
    }
  }
  ALBEDO = vec3(d);
}

