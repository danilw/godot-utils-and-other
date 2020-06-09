shader_type canvas_item;
render_mode blend_add;
uniform float alpha=1.;

// using https://www.shadertoy.com/view/MlGczh

float LookUp (vec2 p, vec2 offset, vec2 res, sampler2D tx)
{
    float offsetScale = 1.0;   
    vec2 uv = p + offset * offsetScale;
    vec4 col = textureLod(tx, uv/res.xy,0.);
	
	return col.a;
	//return 0.212 * col.r + 0.715 * col.g + 0.072 * col.b;
}

vec3 SobelFilter (vec2 uv, vec2 res, sampler2D tx)
{
    float tl = LookUp (uv, vec2 (-1.0, 1.0), res, tx);
    float tc = LookUp (uv, vec2 (0.0, 1.0), res, tx);
    float tr = LookUp (uv, vec2 (1.0, 1.0), res, tx);
    
    float l = LookUp (uv, vec2 (-1.0, 0.0), res, tx);
    float c = LookUp (uv, vec2 (0.0, 0.0), res, tx);
    float r = LookUp (uv, vec2 (1.0, 0.0), res, tx);
    
    float bl = LookUp (uv, vec2 (-1.0, -1.0), res, tx);
    float bc = LookUp (uv, vec2 (0.0, -1.0), res, tx);
    float br = LookUp (uv, vec2 (1.0, -1.0), res, tx);
    
    float gx = tl - tr + 2.0 * l - 2.0 * r + bl - br;
    float gy = -tl - 2.0*tc - tr + bl + 2.0 * bc + br;
    
    return vec3 (gx, gy, sqrt (gx * gx + gy * gy));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution, sampler2D tx)
{
	fragColor=vec4(0.);
    vec2 uv = fragCoord/iResolution.xy;	    
    float aspectRatio = iResolution.x/iResolution.y;
    
    vec3 sobelFilter = SobelFilter (fragCoord, iResolution, tx);
    float gradient = sobelFilter.x * sobelFilter.x + sobelFilter.y * sobelFilter.y;
	
	gradient=clamp(gradient,0.,1.);
   	fragColor.rgb = vec3 (gradient*0.52, pow (gradient, 0.4), gradient*0.8);
	fragColor.a=gradient*alpha;
}

void fragment(){
    vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
    mainImage(COLOR,UV*iResolution,iResolution, TEXTURE);
}
