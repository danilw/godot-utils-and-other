// THIS SHADER MUST BE APPLIED TO A QUAD (MeshInstance) WITH A SIZE OF (2, 2)
// add MeshInstance-Quad to your Camera and copy paste this shader to quad material - shader material
// and on Quad set Center_offset z to -1 
// AND on Material-Render Priority set 127
// used shader https://godotshaders.com/shader/screen-space-edge-detection-outline-shader/ Written by Warren Jennings

// modified 2022, by Danil:
// added Cavity-like style of edge, look below "Cavity formula" comment
// added method 4 - Sobel filter

shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,unshaded;

uniform int outline_mode : hint_range(1, 4, 1) = 3;
uniform float outline_intensity : hint_range(0, 10) = 1;
uniform float outline_bias : hint_range(-10, 10) = 0;

uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform bool display_edge_only = false;
uniform bool display_cavity = false;

uniform float THRESHOLD = 0.2;

varying flat mat4 model_view_matrix;
void vertex() {
  POSITION = vec4(VERTEX, 1.0);
  model_view_matrix = MODELVIEW_MATRIX;
}

void fragment() {
	ALBEDO = outline_color.rgb;
  ALPHA=0.;
	
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 1));
	
	float px = 0.5/screen_size.x;
	float py = 0.5/screen_size.y;
	
	float d = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	float du = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, py)).x;
	float dd = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, -py)).x;
	float dr = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, 0.0)).x;
	float dl = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, 0.0)).x;
  
	if (outline_mode == 1){
		ALPHA = 0.0 + abs(abs(d)-abs(du)) + abs(abs(d)-abs(dd)) + abs(abs(d)-abs(dl)) + abs(abs(d)-abs(dr));
			
		ALPHA *= 1000.0*outline_intensity;
	} else if (outline_mode == 2) {
		ALPHA = 0.0 + abs(abs(abs(d)-abs(du)) - abs(abs(d)-abs(dd))) + abs(abs(abs(d)-abs(dl)) - abs(abs(d)-abs(dr)));
		
		ALPHA *= 3.0*50000.0*outline_intensity;
	} else if (outline_mode == 3) {
		float dq = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, py)).x;
		float de = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, py)).x;
		float dz = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, -py)).x;
		float dc = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, -py)).x;
		
		ALPHA = 0.0 + abs(abs(abs(d)-abs(du)) - abs(abs(d)-abs(dd))) + abs(abs(abs(d)-abs(dl)) - abs(abs(d)-abs(dr))) + abs(abs(abs(d)-abs(dq)) - abs(abs(d)-abs(dc))) + abs(abs(abs(d)-abs(dz)) - abs(abs(d)-abs(de)));

		ALPHA *= 50000.0*outline_intensity;
	} else if (outline_mode == 4) {
    float sobel0[9] = float[9](
        -1.,-2.,-1.,
         0., 0., 0.,
         1., 2., 1.
    );
    float sobel1[9] = float[9](
        -1., 0., 1.,
        -2., 0., 2.,
        -1., 0., 1.
    );
    vec2 value = vec2(0);

    for (int mat_id = 0; mat_id < 2; mat_id++) {
        for (int i = 0; i < 3; i++){
            for (int j = 0; j < 3; j++){
              vec2 offset = vec2(float(i - 1), float(j - 1)) *1./screen_size;
              float kernel = mat_id==0?sobel0[i+j*3]:sobel1[i+j*3];
              vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
              float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));

              if(mat_id==0)value.x += luma * kernel;else value.y += luma * kernel;
            }
        }
    }
    
    ALPHA = step(THRESHOLD, length(value)) * length(value);
  }
	
  if (outline_mode <= 3)ALPHA += outline_bias;
  
	ALPHA=clamp(ALPHA,0.,1.);
  
  if(display_edge_only){
    ALBEDO=vec3(1.-ALPHA);
    ALPHA=1.;
  }else {
    ALPHA *= outline_color.a;
    if(display_cavity){
      vec3 scr_col=texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
      
      // Cavity-fake color formula, feel free to change to mix
      //ALBEDO = outline_color.rgb*scr_col*scr_col+outline_color.rgb*0.25;// basic Cavity example
      
      float td=(0.5-length(scr_col*.5+scr_col*scr_col)*1.75);
      ALBEDO = outline_color.rgb*scr_col*scr_col+scr_col*(td)*3.5+0.25*outline_color.rgb*(1.-td);
      ALBEDO = clamp(ALBEDO*1.5,0.,1.);
      
     }
  }
    METALLIC = 0.001;
    ROUGHNESS = 0.999;
    SPECULAR = 0.5;
}