shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley,
    specular_schlick_ggx, unshaded;

uniform sampler2D texture_1 : hint_albedo;
uniform sampler2D texture_2 : hint_albedo;
uniform sampler2D texture_3 : hint_albedo;
uniform sampler2D texture_4 : hint_albedo;
uniform sampler2D texture_5 : hint_albedo;

uniform sampler2D panorama_bg;
uniform sampler2D floor_texture;
uniform sampler2D floor_tile;
uniform sampler2D pallte;
uniform sampler2D chbtex;

uniform vec4 single_light_color:hint_color;
uniform vec4 border_light_color:hint_color;
uniform sampler2D light_data : hint_albedo;
const vec2 real_size = vec2(4., 8.);

const vec2 light_data_size = vec2(40., 80.);

varying vec2 uv1[4];
varying vec2 uv1m[4];
varying float posz;

float rand(vec2 co) {
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

mat3 rotx(float a){float s = sin(a);float c = cos(a);return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c));  }
mat3 roty(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));}
mat3 rotz(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0 ));}

vec2 rot_uv_180(vec2 uv, vec3 nor) {
  vec2 ts = vec2(1. / 4., 1. / 3.);
  if ((nor.z > 0.) && (nor.x > 0.))
    uv = uv + vec2(-1. * (ts.y), 0. * (2. * ts.x));
  else if ((nor.z > 0.))
    uv = uv + vec2(-1. * (ts.y), 1. * (2. * ts.x));

  if ((nor.z < 0.) && (nor.x < 0.))
    uv = uv + vec2(-2. * (ts.y), 0. * (2. * ts.x));
  else if ((nor.z < 0.))
    uv = uv + vec2(1. * (ts.y), 1. * (2. * ts.x));

  if ((nor.y > 0.))
    uv = vec2(1. - uv.x, 3. * ts.x - uv.y);
  else if ((nor.y < 0.))
    uv = vec2(1. - uv.x + 2. * ts.y, 3. * ts.x - uv.y);

  return uv;
}

vec2 rot_uv_90(vec2 uv, vec3 nor) {
  vec2 ts = vec2(1. / 4., 1. / 3.);
  if ((nor.z > 0.) && (nor.x > 0.))
    uv = uv + vec2(-0. * (ts.y), 1. * (2. * ts.x));
  else if ((nor.z > 0.))
    uv = uv + vec2(-1. * (ts.y), 2. * (2. * ts.x));

  if ((nor.z < 0.) && (nor.x < 0.))
    uv = uv + vec2(-1. * (ts.y), 0. * (2. * ts.x));
  else if ((nor.z < 0.))
    uv = uv + vec2(-1. * (ts.y), 1. * (2. * ts.x));

  if ((nor.y > 0.))
    uv = vec2(((uv.y - 2. * ts.x) * 1. / ts.x) * ts.y + 2. * ts.y,
              3. * ts.x - (((uv.x - ts.y) * 1. / ts.y) * ts.x + ts.x));
  else if ((nor.y < 0.))
    uv = vec2(1. - (((uv.y - 0. * ts.x) * 1. / ts.x) * ts.y + 1. * ts.y) +
                  2. * ts.y,
              (((uv.x - ts.y) * 1. / ts.y) * ts.x + 0. * ts.x));

  return uv;
}

vec2 rot_uv_m(vec2 uv, vec3 nor) {
  vec2 ts = vec2(1. / 4., 1. / 3.);
  if ((nor.z > 0.) && (nor.x > 0.)) {
    uv = uv + vec2(1. * (ts.y), 0. * (2. * ts.x));
    uv.x = 1. - uv.x;
  } else if ((nor.z > 0.)) {
    uv = uv + vec2(-1. * (ts.y), 0. * (2. * ts.x));
    uv.x = 1. - uv.x + 1. * ts.y;
  }

  if ((nor.z < 0.) && (nor.x < 0.)) {
    uv = uv + vec2(-2. * (ts.y), 1. * (2. * ts.x));
    uv.x = 1. - uv.x + 1. * ts.y;
  } else if ((nor.z < 0.)) {
    uv = uv + vec2(-1. * (ts.y), 1. * (2. * ts.x));
    uv.x = 1. - uv.x - 1. * ts.y;
  }

  if ((nor.y > 0.))
    uv = vec2(1. - ((uv.y - 2. * ts.x) * 1. / ts.x) * ts.y + 2. * ts.y +
                  2. * ts.y,
              3. * ts.x - (((uv.x - ts.y) * 1. / ts.y) * ts.x + ts.x));
  else if ((nor.y < 0.))
    uv = vec2(1. - (((uv.y - 0. * ts.x) * 1. / ts.x) * ts.y + 1. * ts.y) +
                  2. * ts.y,
              (1. - ((uv.x - ts.y) * 1. / ts.y) * ts.x + 3. * ts.x));

  return uv;
}

vec2 rot_uv(vec2 uv, vec3 nor, int ang) {
  if (ang == 0) {
    return uv;
  }

  if (ang == 1) {
    uv = rot_uv_180(uv, nor);
    return uv;
  }
  if (ang == 2) {
    uv = rot_uv_90(uv, nor);
    return uv;
  }
  if (ang == 3) {
    uv = rot_uv_180(rot_uv_90(uv, nor), nor * roty(3.1415926 / 2.));
    return uv;
  }

  return uv;
}

vec3 get_posz_cube(vec3 wmpos){
  vec2 shiftpos=(real_size-light_data_size)*vec2(1.,0.5)*4.;
  wmpos+=-vec3(shiftpos.x,0.,shiftpos.y);
  float obj_size=1.;
  float tva=(((light_data_size.x/2.)*12.*0.5-(wmpos.z-obj_size*0.5))/12.)/(light_data_size.x/2.);
  float va=tva;
  float fx=floor((1.0/6.0)*(light_data_size.x/2.))*2.;
  float tvb=(((light_data_size.x/2.+fx)*12.*0.5-(wmpos.x-obj_size*0.5))/12.)/(light_data_size.x/2.+fx);
  float vb=abs(tvb);
  va+=0.2;
  float z=(1.0 - (pow(va, 2.0) + pow(vb, 2.0)));
  return vec3(va,tvb,z-1.);
}

void vertex() {
  
  vec3 poszt=get_posz_cube((WORLD_MATRIX[3].xyz+vec3(0.5,0.,-11.5)));
  posz=poszt.z;
  mat3 rotmx=rotx(sign(poszt.x)*.5*pow(poszt.x, 2.0));
  mat3 rotmxm=rotx(-sign(poszt.x)*.5*pow(poszt.x, 2.0));
  
  mat3 rotmy=rotz(-sign(poszt.y)*.5*pow(poszt.y, 2.0));
  mat3 rotmym=rotz(sign(poszt.y)*.5*pow(poszt.y, 2.0));
  VERTEX=VERTEX*rotmx*rotmy;
  VERTEX.y+=posz*50.-0.15;
  VERTEX.z+=-(vec3(0.,1.,0.)*rotmxm).z*1.;
  VERTEX.x+=(vec3(1.,0.,0.)*rotmym).y*0.75;
  VERTEX.xz*=01.025;
  
  uv1[3] = rot_uv(UV, NORMAL, 0);
  uv1[1] = rot_uv(UV, NORMAL, 1);
  uv1[2] = rot_uv(UV, NORMAL, 2);
  uv1[0] = rot_uv(UV, NORMAL, 3);
  uv1m[3] = rot_uv_m(uv1[3], NORMAL);
  uv1m[1] = rot_uv_m(uv1[1], NORMAL * vec3(-1., 1., -1.));
  uv1m[2] = rot_uv_m(uv1[2], NORMAL * roty(3.1415926 / 2.));
  uv1m[0] =
      rot_uv_m(uv1[0], NORMAL * vec3(-1., 1., -1.) * roty(3.1415926 / 2.));
}

vec3 decodeSRGB(vec3 screenRGB) {
  vec3 a = screenRGB / 12.92;
  vec3 b = pow((screenRGB + 0.055) / 1.055, vec3(2.4));
  vec3 c = step(vec3(0.04045), screenRGB);
  return mix(a, b, c);
}

vec2 uv_sphere(vec3 v) {
  float pi = 3.1415926536;
  return vec2(0.5 + atan(v.z, v.x) / (2.0 * pi), acos(v.y) / pi);
}

vec3 gridTexture(vec2 p,vec3 light_pos,float iTime, float iscb){
  float d=0.;
  d=1.-smoothstep(0.,2.,length(p+light_pos.xz));
  d=max(d,1.-smoothstep(0.,3.5,length(p+vec2(0.,-0.025))));
  float intensity=(0.15+0.45*(p.y*(1.-smoothstep(0.,2.,abs(p.x)))));
  vec2 rOffset = vec2(-0.02,0)*intensity;
  vec2 gOffset = vec2(0.0,0)*intensity;
  vec2 bOffset = vec2(0.04,0)*intensity;
  vec3 col=vec3(texture(floor_tile,p+rOffset,iscb).r,texture(floor_tile,p+gOffset,iscb).g,texture(floor_tile,p+bOffset,iscb).b);
  col*=d;
  col*=texture(floor_texture,(p)*0.18+light_pos.xz).r;
  return pow(col,vec3(2.));
}

float iPlane( in vec3 ro, in vec3 rd )
{
    return (-1.0 - ro.y)/rd.y;
}

vec2 sphere(in vec3 ro, in vec3 rd, in float r, out vec3 ni) {
  float pd = dot(ro, rd);
  float disc = pd * pd + r * r - dot(ro, ro);
  if (disc < 0.)
    return vec2(-1.);
  float tdiff = sqrt(disc);
  float tin = -pd - tdiff;
  float tout = -pd + tdiff;
  ni = normalize(ro + tin * rd);

  return vec2(tin, tout);
}

void mi(out vec4 fragColor, in vec2 p, float iTime, float iscb) {
  p *= 0.25;
  p = 0.5 * p / dot(p, p);
  vec2 q = p;
  p.y += mod(iTime * 0.5, 1. / 0.4); // loop no float precious loss

  vec3 col = texture(pallte, vec2(0.4 * p.y, 0.),iscb).rgb;

  col *= 1.4 - 0.07 * length(q);

  col = clamp(col, 0., 1.);
  fragColor = vec4(col, 1.0);
}

void fragment() {
  vec3 rdn=normalize(((CAMERA_MATRIX) * vec4(normalize(VERTEX), 0.0)).xyz);
  vec3 nor=normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
  
  vec3 res_col = vec3(0.);
  vec3 ref_col = vec3(0.);
  
  float iscb=texture(chbtex,(UV2+vec2(0.5,0.15))*vec2(1.5,2.)*1.5).r;
  
  for (int i = 0; i < 8; i++) {
    vec3 col = vec3(0.);
    vec2 id_pos = vec2(0.);
    if (i < 4) {
      id_pos = floor(
          (WORLD_MATRIX[3].zx +
           vec2(-4. * (mod(float(i), 2.) * (1. - 2. * float((i + 2) / 4))),
                4. *
                    (mod(float(i + 1), 2.) * (1. - 2. * float((i + 3) / 4))))) *
          vec2(0.5, 1.) * vec2(1. / 4.));
    } else {
      int ti = i - 4;
      id_pos = floor((WORLD_MATRIX[3].zx +
                      3. * vec2(-4. * (mod(float(ti), 2.) *
                                       (1. - 2. * float((ti + 2) / 4))),
                                4. * (mod(float(ti + 1), 2.) *
                                      (1. - 2. * float((ti + 3) / 4))))) *
                     vec2(0.5, 1.) * vec2(1. / 4.));
    }
    if (any(lessThan(id_pos, vec2(-0.001)))||any(greaterThan(id_pos, vec2(real_size)-0.001)))
    {}else{
    vec4 light_data_vals =
        textureLod(light_data, (id_pos + 0.5) / real_size, 0.)*single_light_color;
    float light_power = mix(light_data_vals.w * 2.,light_data_vals.w*light_data_vals.w,light_data_vals.w);
    vec3 light_color = light_data_vals.rgb;
    float d = 0.;
    // EDIT NEXT LINE
    if (i == 3) {
      d = texture(texture_1, uv1[i]).r;
      
      vec3 tref_col=vec3(0.);
      {
          vec3 ref = refract(rdn,nor,0.851);
          vec3 ro=CAMERA_MATRIX[3].xyz-WORLD_MATRIX[3].xyz;
          vec3 light_pos=vec3(0.,-0.5,-04.);
          ro.y+=-(posz*50.-0.);
          float t1 = iPlane( ro, ref );
          if( t1>0.0 )
          {
            vec3 posx = ro + t1*ref;
            tref_col=light_power*light_color * gridTexture( 4.*(1./12.)*posx.xz+vec2(0.,0.75*(1./12.)),4.*(1./12.)*light_pos,TIME, iscb*5.);
          }
          
          ro+=light_pos;
          vec3 ni;
          vec2 t = sphere(ro, ref, 1., ni);
          if(t.x>0.){
            vec3 rd2 = ro + t.x * ref;
          
            float intensity = clamp(pow(0.32122 + max(dot(ni, normalize(-ref)), 0.), 010.85),0.,1.);
            vec4 tcol = vec4(0.);
            mi(tcol,rd2.zx,TIME, iscb*5.);
            vec3 tex = tcol.rgb;
            //tex = light_color * intensity * tex * light_power;
            tref_col=mix(tref_col,tex.rgb*intensity*light_color,intensity);
          }
      }
      ref_col = (ref_col + tref_col) + 2.5 * tref_col * ref_col;
      ref_col = clamp(ref_col, 0., 1.);
      
    } else {
      d = texture(texture_2, uv1[i - 4]).r;
    }
    col =
        light_color.rgb * d * 0.75 +
        0.75 *
            clamp((-light_color.rgb + light_color.rgb / max(1. - d, 0.10001)) *
                      0.125,
                  0., 1.);
    col *= light_power;
    res_col = (res_col + col) + 2.5 * col * res_col;
    res_col = clamp(res_col, 0., 1.);
    }
    
    col = vec3(0.);
    id_pos = vec2(0.);
    if (i < 4) {
      id_pos = floor(
          (WORLD_MATRIX[3].zx +
           vec2(-4. * (mod(float(i), 2.) * (1. - 2. * float((i + 2) / 4))),
                4. * (mod(float(i + 1), 2.) * (1. - 2. * float((i + 3) / 4)))) +
           vec2(4., 4.) * vec2(1. - 2. * min(mod(float(i), 3.), 1.),
                               (1. - 2. * float((i) / 2)))) *
          vec2(0.5, 1.) * vec2(1. / 4.));
    } else {
      int ti = i - 4;
      id_pos = floor(
          (WORLD_MATRIX[3].zx +
           vec2(-4. * (mod(float(ti), 2.) * (1. - 2. * float((ti + 2) / 4))),
                4. * (mod(float(ti + 1), 2.) *
                      (1. - 2. * float((ti + 3) / 4)))) +
           2. * vec2(4., 4.) *
               vec2(1. - 2. * min(mod(float(ti), 3.), 1.),
                    (1. - 2. * float((ti) / 2)))) *
          vec2(0.5, 1.) * vec2(1. / 4.));
    }
    if (any(lessThan(id_pos, vec2(-0.001)))||any(greaterThan(id_pos, vec2(real_size)-0.001)))
    {}else{
    vec4 light_data_vals =
        textureLod(light_data, (id_pos + 0.5) / real_size, 0.)*single_light_color;
    float light_power = mix(light_data_vals.w * 2.,light_data_vals.w*light_data_vals.w,light_data_vals.w);
    vec3 light_color = light_data_vals.rgb;
    float d = 0.;
    if (i < 4) {
      d = texture(texture_3, uv1[i]).r;
    } else {
      d = texture(texture_4, uv1[i - 4]).r;
    }
    col =
        light_color.rgb * d * 0.75 +
        0.75 *
            clamp((-light_color.rgb + light_color.rgb / max(1. - d, 0.10001)) *
                      0.125,
                  0., 1.);
    col *= light_power;
    res_col = (res_col + col) + 2.5 * col * res_col;
    res_col = clamp(res_col, 0., 1.);
    }
    
    col = vec3(0.);
    id_pos = vec2(0.);
    if (i < 4) {
      id_pos = floor(
          (WORLD_MATRIX[3].zx +
           vec2(-4. * (mod(float(i), 2.) * (1. - 2. * float((i + 2) / 4))),
                4. * (mod(float(i + 1), 2.) * (1. - 2. * float((i + 3) / 4)))) +
           vec2(-4., 4.) * vec2(1. - 2. * min(max(float(i) - 1., 0.), 1.),
                                (1. - 2. * min(mod(float(i), 3.), 1.)))) *
          vec2(0.5, 1.) * vec2(1. / 4.));
    } else {
      int ti = i - 4;
      id_pos = floor(
          (WORLD_MATRIX[3].zx +
           vec2(-4. * (mod(float(ti), 2.) * (1. - 2. * float((ti + 2) / 4))),
                4. * (mod(float(ti + 1), 2.) *
                      (1. - 2. * float((ti + 3) / 4)))) +
           2. * vec2(-4., 4.) *
               vec2(1. - 2. * min(max(float(ti) - 1., 0.), 1.),
                    (1. - 2. * min(mod(float(ti), 3.), 1.)))) *
          vec2(0.5, 1.) * vec2(1. / 4.));
    }
    if (any(lessThan(id_pos, vec2(-0.001)))||any(greaterThan(id_pos, vec2(real_size)-0.001)))
    {}else{
    vec4 light_data_vals =
        textureLod(light_data, (id_pos + 0.5) / real_size, 0.)*single_light_color;
    float light_power = mix(light_data_vals.w * 2.,light_data_vals.w*light_data_vals.w,light_data_vals.w);
    vec3 light_color = light_data_vals.rgb;
    float d = 0.;
    if (i < 4) {
      d = texture(texture_3, uv1m[i]).r;
    } else {
      d = texture(texture_4, uv1m[i - 4]).r;
    }
    col =
        light_color.rgb * d * 0.75 +
        0.75 *
            clamp((-light_color.rgb + light_color.rgb / max(1. - d, 0.10001)) *
                      0.125,
                  0., 1.);
    col *= light_power;
    res_col = (res_col + col) + 2.5 * col * res_col;
    res_col = clamp(res_col, 0., 1.);
  }
  }
  
  vec2 id_gpos=floor((WORLD_MATRIX[3].zx) * vec2(0.5, 1.) * vec2(1. / 4.));
  bvec4 is_border=bvec4(false);
  is_border=bvec4(
    (id_gpos.x<0.5)&&(floor(mod(id_gpos.y,2.))>0.5),
    (id_gpos.y<0.5),
    (id_gpos.x>0.5+real_size.x-2.)&&(floor(mod(id_gpos.y,2.))>0.5),
    (id_gpos.y>0.5+real_size.y-3.)
   );
  if(any(is_border)){
    vec2 tuv2=uv1[0];
    if(is_border[0]){
      tuv2=uv1[3];
    }else
    if(is_border[1]){
      tuv2=uv1[0];
    }else
    if(is_border[2]){
      tuv2=uv1[1];
    }else
    if(is_border[3]){
      tuv2=uv1[2];
    }
  
    float detx=texture(texture_5,tuv2).r;
    detx=detx*detx*01.15+detx*0.5;
    res_col+=pow(detx*border_light_color.rgb,vec3(1.1));
  }
  float rv = (rand(SCREEN_UV) - .5) * .067;
  ALBEDO = res_col * 1. + rv;
  
  ALBEDO=clamp(ALBEDO,0.,1.);
  vec2 tuv=uv_sphere(rdn);
  tuv.x = fract(tuv.x + 0.75);
  ALBEDO=mix(ALBEDO,texture(panorama_bg,tuv).rgb, smoothstep(39., 149.9,
                       length(WORLD_MATRIX[3].xyz - CAMERA_MATRIX[3].xyz)));
  
  ALBEDO=ALBEDO*iscb+ref_col*(1.-iscb*0.35);
  if (!OUTPUT_IS_SRGB) {
    ALBEDO = decodeSRGB(ALBEDO);
  }
}
