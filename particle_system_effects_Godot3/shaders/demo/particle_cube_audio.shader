shader_type spatial;
render_mode blend_add,depth_draw_never,cull_back,unshaded;

uniform float iTime=0.;
uniform sampler2D iChannel0;

varying float ti;
varying float tj;
varying float tz;
varying float tw;

vec4 get_acol(vec2 p)
{
	p.x+=0.15+0.15*cos(iTime*0.35);
	p=clamp(p,0.,1.);
	p=p.yx;
	p.y=1.-p.y;
    float fft  = texture( iChannel0, vec2(p.x,0.0) ).x;
    vec3 color = mix(vec3(0.0, 2.0, 0.0), vec3(2.0, 0.0, 0.0), sqrt(p.y));
    float mask = (p.y < fft) ? 1.0 : 0.0;
	
    vec3 ledColor = color*mask;

    return vec4(ledColor, 1.);
}


float rand(float p)
{
	vec3 p3  = fract(vec3(p) * 3.10432);
    p3 += dot(p3, p3.yzx + 15.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 get_color(vec3 col,vec3 tcol, float ttimer, inout float ttw){
    float tvx=smoothstep(0.,6.,ttimer);
	float tvx2=smoothstep(3.,10.,ttimer);
	float tvx3=1.-smoothstep(3.,8.,ttimer);
	float tvy=1.-smoothstep(5.,10.,ttimer);
	float vx=0.;
	float vx2=0.;
	vx2=smoothstep(6.+25.*tvx-10.-5.*tvx3,7.+25.*tvx-10.,tz)*(1.-smoothstep(7.+25.*tvx-10.,8.+25.*tvx-10.,tz));
	vx=smoothstep(0.+25.*tvx2-5.,7.+25.*tvx2-5.,tz)*(1.-smoothstep(7.+25.*tvx-10.,8.+25.*tvx-10.,tz));
	float tva=smoothstep(-.5,7.,tz)*(1.-smoothstep(7.,19.5,tz));
	tva=tva*(1.-tvx*tvy);
	tcol*=01.*vx+0.95*tva;
	ttw=max(1.-tva,ttw);
	col=((0.+5.*vx+14.*vx2)*col+8.*tcol*(1.-vx*vx2));
	return col;
}

// how it work: lighting hapens in 2d-UV space, vertex coordinates calculated in fake-view-projection logic
// rotationfixed to be face-camera, to see bilboard mode uncomment mtx= line in VERTEX function

vec3 my_normalize3(vec3 v){
	float len = length(v);
	vec3 ret=vec3(0.);
	if(len==0.0)ret= vec3(1.0,0.0,0.0);
	else ret= v/len;
	return ret;
}

mat4 lookAt(vec3 from, vec3 to, vec3 tup ) 
{ 
	vec3 forward = my_normalize3(from - to); 
	if(length(forward.xz)<=0.001)forward.x=0.001;
	vec3 right = cross(normalize(tup), forward); 
	right = my_normalize3(right);
	vec3 up = cross(forward, right); 
	mat4 camToWorld=mat4(1.); 
	
	camToWorld[0][0] = right.x; 
	camToWorld[0][1] = right.y; 
	camToWorld[0][2] = right.z; 
	camToWorld[1][0] = up.x; 
	camToWorld[1][1] = up.y; 
	camToWorld[1][2] = up.z; 
	camToWorld[2][0] = forward.x; 
	camToWorld[2][1] = forward.y; 
	camToWorld[2][2] = forward.z; 
	
	camToWorld[3][0] = from.x; 
	camToWorld[3][1] = from.y; 
	camToWorld[3][2] = from.z; 
	
	return camToWorld; 
}

varying mat4 mtx;

void vertex() {
	// bilboard project
	//mtx = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
	
	// lookAt project, comment/uncomment
  vec3 cam_pos = CAMERA_MATRIX[3].xyz;
	mtx=lookAt(cam_pos,WORLD_MATRIX[3].xyz,vec3(0.,1.,0.));
	
	mtx[3].xyz=WORLD_MATRIX[3].xyz;

	MODELVIEW_MATRIX=INV_CAMERA_MATRIX*mtx;
	
	tz=INSTANCE_CUSTOM.w;
	ti=float(INSTANCE_ID%15);
	tj=float(INSTANCE_ID/15);
	float ttw=0.;
	COLOR=vec4(get_color(vec3(0.11,0.21,0.91),vec3(0.9,0.11,0.1),min(mod(iTime,20.),12.),ttw),1.);
	COLOR=max(COLOR,vec4(get_color(vec3(0.81,0.41,0.01),vec3(0.9,0.01,0.01),mod(iTime*2.+rand(tj)*12.,12.),ttw),1.));
	COLOR.rgb+=4.*COLOR.rgb*get_acol(vec2(ti,tj)/vec2(15.,10.)).rgb;
	tw=ttw;
}
 
float line( vec2 a, vec2 b, vec2 p , float ji, float js)
{
	float jitterIntensity = 0.00251*ji;
    float jitter = rand(sin(iTime*0.672)+js) * jitterIntensity;
    vec2 aTob = b - a;
    vec2 aTop = p - a;
    float t = dot( aTop, aTob ) / dot( aTob, aTob);
    t = clamp( t, 0.0, 1.0);
    float d = length( p - (a + aTob * t) );
    d = (0.065+jitter-0.056*tw) / max(d,0.001);
    d = pow(d, 7.0);
    return clamp( d, 0., 1.0 );
}

mat4 perspectiveMatrix(float fovYInRad, float aspectRatio)
{
    float yScale = 1.0/tan(fovYInRad / 2.0);
    float xScale = yScale / aspectRatio;
    float zf = 100.0;
    float zn = 0.3;
 
    float z1 = zf/(zf-zn);
    float z2 = -zn*zf/(zf-zn);
 
    mat4 result = mat4(vec4(xScale, 0.0, 0.0, 0.0),
              vec4(0.0, yScale, 0.0, 0.0),
              vec4(0.0, 0.0, z1, z2),
              vec4(0.0, 0.0, -1.0, 0.0));
 
    return result;
}

mat4 translationMatrix(vec3 pos)
{
    mat4 result = 
    mat4(vec4(1.0, 0.0, 0.0, 0.0), 
         vec4(0.0, 1.0, 0.0, 0.0),
         vec4(0.0, 0.0, 1.0, 0.0),
         vec4(pos.x, pos.y, pos.z, 1.0));
 
    return result;
}
 
mat4 rotX(float theta)
{
    float cs = cos(theta);
    float ss = sin(theta);
 
    mat4 result = 
    mat4(vec4(1.0, 0.0, 0.0, 0.0), 
         vec4(0.0, cs, -ss, 0.0),
         vec4(0.0, ss, cs, 0.0),
         vec4(0.0, 0.0, 0.0, 1.0));
 
    return result;
}
 
mat4 rotY(float theta)
{
    float cs = cos(theta);
    float ss = sin(theta);
 
    mat4 result = 
    mat4(vec4(cs, 0.0, -ss, 0.0), 
         vec4(0.0, 1.0, 0.0, 0.0),
         vec4(ss, 0.0, cs, 0.0),
         vec4(0.0, 0.0, 0.0, 1.0));
 
    return result;
}
 
void process_verts( out vec4 fragColor, in vec2 p,vec3 vtx, vec3 icol)
{
    vec2 uv = p * 2.0 - 1.0;
	vec2 ouv=uv;
	uv.y=-uv.y;
	
	vec3 ccol=clamp(icol,0.,1.);
    uv *= 5.0;
 
    const float fovYInRad = (45.0/180.0) * 3.14159;
 
    const float vs = 10.0;
    vec4 verts [16];
    verts[0] = vec4( -vs, -vs, vs, 1.0 );
    verts[1] = vec4( -vs,  vs, vs, 1.0 );
    verts[2] = vec4(  vs,  vs, vs, 1.0 );
    verts[3] = vec4(  vs, -vs, vs, 1.0 );
 
    verts[4] = vec4( -vs, -vs, vs, 1.0 );
    verts[5] = vec4( -vs,  vs, vs, 1.0 );
    verts[6] = vec4( -vs,  vs, -vs, 1.0 );
    verts[7] = vec4( -vs, -vs, -vs, 1.0 );
 
    verts[8] = vec4( -vs, -vs, -vs, 1.0 );
    verts[9] = vec4( -vs,  vs, -vs, 1.0 );
    verts[10] = vec4( vs,  vs, -vs, 1.0 );
    verts[11] = vec4( vs, -vs, -vs, 1.0 );
 
    verts[12] = vec4( vs, -vs, vs, 1.0 );
    verts[13] = vec4( vs,  vs, vs, 1.0 );
    verts[14] = vec4( vs,  vs, -vs, 1.0 );
    verts[15] = vec4( vs, -vs, -vs, 1.0 );
	
	float moveX=0.;
	float moveY=0.;
	float moveZ=60.;
 
    vec3 pos = vec3( moveX, moveY, moveZ);
	//pos=pos-vtx*5.; //bad perspective fix
    //mat4 rotY = rotY(tj*0.51) * rotX(0.);
	mat4 tmtx=mtx;
	tmtx[3].xyz=vec3(0.);
	
    mat4 worldMat = translationMatrix(pos) *inverse(tmtx);//* rotY ;
    mat4 perspective = perspectiveMatrix(fovYInRad, 1.);
 
    mat4 mvp = perspective * worldMat;
 
    float t = 0.0;
    for(int i = 0; i < 16; ++i)
    {
        vec4 startWorldVert = mvp * verts[i];
        vec4 endWorldVert;
        if( i+1 < 16)
        {
            endWorldVert = mvp * verts[i + 1];
        }
        else
        {
            endWorldVert = mvp * verts[i - 3];
        }
 
        if(i != 0 && mod(float(i+1), 4.0) == 0.0)
        {
            endWorldVert = mvp * verts[i - 3];
        }
 
        if((startWorldVert.w<=-1.001)&&(endWorldVert.w<=-1.001)){
            vec2 sp = startWorldVert.xy / startWorldVert.w;
            vec2 ep = endWorldVert.xy / endWorldVert.w;
            t += line(sp, ep, uv, 1.-ccol.r*(1.-ccol.g)*(1.-ccol.b), .75*dot(ccol,vec3(1.))*3.);
        }
    }
	
    vec3 fc = vec3( 0.0 );
	
	
	fc +=  icol* pow(t, 0.2);
	
	
	fc*=1.-dot(ouv*0.5,ouv*0.5);
	fc*=1.-smoothstep(0.7,1.,length(ouv));
    fragColor = vec4( fc, 1.0 );
 
}

void fragment() {
	vec4 col=vec4(0.);
	process_verts(col,UV,VERTEX, COLOR.rgb);
  vec3 cam_pos = CAMERA_MATRIX[3].xyz;
	float fade_distance=length(mtx[3].xyz-cam_pos);
	float fade=clamp(smoothstep(0.25,1.,fade_distance),0.0,1.0);
    ALBEDO = col.rgb*fade;
}
