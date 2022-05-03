shader_type canvas_item;
render_mode blend_premul_alpha,unshaded;

uniform sampler2D edge_vp;
uniform sampler2D color_vp;
uniform sampler2D noise_tx;
uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform bool use_curve_edges=false;
uniform bool display_edge_only = false;
uniform bool display_cavity = false;
uniform bool use_real_cav = false;


uniform float NoiseAmount =0.01;
uniform float ErrorPeriod =30.0;
uniform float ErrorRange =0.003;

vec3 encodeSRGB(vec3 linearRGB)
{
    vec3 a = 12.92 * linearRGB;
    vec3 b = 1.055 * pow(linearRGB, vec3(1.0 / 2.4)) - 0.055;
    vec3 c = step(vec3(0.0031308), linearRGB);
    return mix(a, b, c);
}

void fragment(){
  COLOR=textureLod(edge_vp,UV,0);
  COLOR.rgb=encodeSRGB(COLOR.rgb);
  if(use_curve_edges){
    float noise = (texture(noise_tx, UV * 0.5).r - 0.5) * NoiseAmount;
    vec2 uvs[3];
    uvs[0] = UV + vec2(ErrorRange * sin(ErrorPeriod * UV.y + 0.0) + noise, ErrorRange * sin(ErrorPeriod * UV.x + 0.0) + noise);
    uvs[1] = UV + vec2(ErrorRange * sin(ErrorPeriod * UV.y + 1.047) + noise, ErrorRange * sin(ErrorPeriod * UV.x + 3.142) + noise);
    uvs[2] = UV + vec2(ErrorRange * sin(ErrorPeriod * UV.y + 2.094) + noise, ErrorRange * sin(ErrorPeriod * UV.x + 1.571) + noise);
    
    vec2 edges[3] = vec2[3](texture(edge_vp, uvs[0]).rg, texture(edge_vp, uvs[1]).rg, texture(edge_vp, uvs[2]).rg);
    if(display_edge_only){
      if(use_real_cav){
        float cav_edge = clamp( (1.0 + edges[0].r) * (1.0 + edges[0].g), 0.0, 4.0)/4.;
        float cav_edge2 = clamp( (1.0 + edges[1].r) * (1.0 + edges[1].g), 0.0, 4.0)/4.;
        float cav_edge3 = clamp( (1.0 + edges[2].r) * (1.0 + edges[2].g), 0.0, 4.0)/4.;
        COLOR.rgb = vec3(cav_edge+cav_edge2+cav_edge3)/3.;
      }else
        COLOR.rgb = vec3(edges[0].r*edges[1].r*edges[2].r);
    }
    else{
      vec4 local_outline_color=outline_color;
      float a=edges[0].r*edges[1].r*edges[2].r;
      if(use_real_cav){
        float cav_edge = max(edges[0].r,abs(edges[0].g)/2.);
        float cav_edge2 = max(edges[1].r,abs(edges[1].g)/2.);
        float cav_edge3 = max(edges[2].r,abs(edges[2].g)/2.);
        a = 1.-(cav_edge+cav_edge2+cav_edge3)/3.;
        a=clamp(a,0.,1.);
        
        vec3 scr_col=outline_color.rgb;
        vec3 c1=clamp( (1.0 + scr_col*edges[0].r) * (1.0 + scr_col*edges[0].g), 0.0, 4.0)/4.;
        vec3 c2=clamp( (1.0 + scr_col*edges[1].r) * (1.0 + scr_col*edges[1].g), 0.0, 4.0)/4.;
        vec3 c3=clamp( (1.0 + scr_col*edges[2].r) * (1.0 + scr_col*edges[2].g), 0.0, 4.0)/4.;
        scr_col=vec3(c1+c2+c3)/1.5;
        scr_col=scr_col*0.5+scr_col*scr_col;
        scr_col=clamp(scr_col,0.,1.);
        local_outline_color.rgb = scr_col;
        edges[0].r=1.-cav_edge;edges[1].r=1.-cav_edge2;edges[2].r=1.-cav_edge3;
        //COLOR.rgb = mix(mix(texture(color_vp,UV).rgb,scr_col,outline_color.a),texture(color_vp,UV).rgb,a);
      }
      if(display_cavity){
        vec3 scr_col=texture(color_vp,UV).rgb;
        scr_col=mix(texture(color_vp,uvs[0]).rgb,scr_col,edges[0].r);
        scr_col=mix(texture(color_vp,uvs[1]).rgb,scr_col,edges[1].r);
        scr_col=mix(texture(color_vp,uvs[2]).rgb,scr_col,edges[2].r);
        
        // Cavity-fake color formula, feel free to change to mix
        //COLOR.rgb = outline_color.rgb*scr_col*scr_col+outline_color.rgb*0.25;// basic Cavity example

        float td=(0.5-length(scr_col*.5+scr_col*scr_col)*1.75);
        COLOR.rgb = local_outline_color.rgb*scr_col*scr_col+scr_col*(td)*1.5+0.25*local_outline_color.rgb*(1.-td);
        COLOR.rgb = clamp(COLOR.rgb*1.5,0.,1.);
        COLOR.rgb = mix(mix(texture(color_vp,UV).rgb,COLOR.rgb,local_outline_color.a),texture(color_vp,UV).rgb,a);
      } else
        COLOR.rgb = mix(mix(texture(color_vp,UV).rgb,local_outline_color.rgb,local_outline_color.a),texture(color_vp,UV).rgb,a);
      //COLOR.rgb=vec3(a);
      }
      
      
   }
  
  //COLOR.a=clamp(COLOR.a,0.,1.);
  COLOR.a=1.;
}
