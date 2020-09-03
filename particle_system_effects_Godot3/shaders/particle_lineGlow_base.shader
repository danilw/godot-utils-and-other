shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_back,unshaded;

uniform float iTime;

uniform vec4 col_a:
hint_color;
uniform vec3 cam_pos;

// how it work: lighting hapens in 2d-UV space, vertex coordinates calculated in fake-view-projection logic
// rotationfixed to be face-camera, to see bilboard mode uncomment mtx= line in VERTEX function

vec3 my_normalize3(vec3 v) {
    float len = length(v);
    vec3 ret=vec3(0.);
    if(len==0.0)ret= vec3(1.0,0.0,0.0);
    else ret= v/len;
    return ret;
}

//both should work
/*
mat4 lookAt(vec3 target, vec3 eye, vec3 up) {
  vec3 zAxis = my_normalize3(target - eye);
  vec3 xAxis = my_normalize3(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    vec4(xAxis, 0),
    vec4(yAxis, 0),
    vec4(zAxis, 0),
    vec4(-dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1));
}
*/

mat4 lookAt(vec3 from, vec3 to, vec3 tup) {
    vec3 forward = my_normalize3(from - to);
    if (length(forward.xz) <= 0.001) forward.x = 0.001;
    vec3 right = cross(normalize(tup), forward);
    right = my_normalize3(right);
    vec3 up = cross(forward, right);
    mat4 camToWorld = mat4(1.);

    camToWorld[0].xyz = right.xyz;
    camToWorld[1].xyz = up.xyz;
    camToWorld[2].xyz = forward.xyz;

    camToWorld[3].xyz = from.xyz;

    return camToWorld;
}

varying mat4 mtx;
void vertex() {
    // bilboard project
    //mtx = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);

    // lookAt project, comment/uncomment
    mtx=lookAt(cam_pos,WORLD_MATRIX[3].xyz,vec3(0.,1.,0.));

    mtx[3].xyz=WORLD_MATRIX[3].xyz;

    MODELVIEW_MATRIX=INV_CAMERA_MATRIX*mtx;

}

float line( vec2 a, vec2 b, vec2 p)
{
    vec2 aTob = b - a;
    vec2 aTop = p - a;
    float t = dot( aTop, aTob ) / dot( aTob, aTob);
    t = clamp( t, 0.0, 1.0);
    float d = length( p - (a + aTob * t) );
    d = (0.025) / max(d,0.001);
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

void process_verts( out vec4 fragColor, in vec2 p,vec3 vtx, vec3 icol)
{
    vec2 uv = p * 2.0 - 1.0;
    vec2 ouv=uv;
    uv.y=-uv.y;

    vec3 ccol=clamp(icol,0.,1.);
    uv *= 5.0;

    const float fovYInRad = (45.0/180.0) * 3.14159;

    const float vs = 10.0;
    vec4 verts [2];
    verts[0] = vec4(  vs-(vs/4.)*8., 0., 0., 1.0 );
    verts[1] = vec4(  vs-(vs/4.)*0., 0., 0., 1.0 );

    float moveX=0.;
    float moveY=0.;
    float moveZ=60.;

    vec3 pos = vec3( moveX, moveY, moveZ);
    //pos=pos-vtx*5.; //bad perspective fix

    mat4 tmtx=mtx;
    tmtx[3].xyz=vec3(0.);

    mat4 worldMat = translationMatrix(pos) *inverse(tmtx);
    mat4 perspective = perspectiveMatrix(fovYInRad, 1.);

    mat4 mvp = perspective * worldMat;

    float t = 0.0;
    for(int i = 0; i < 1; ++i)
    {
        vec4 startWorldVert = mvp * verts[i];
        vec4 endWorldVert;
        endWorldVert = mvp * verts[i + 1];

        if((startWorldVert.w<=-1.001)&&(endWorldVert.w<=-1.001)) {
            vec2 sp = startWorldVert.xy / startWorldVert.w;
            vec2 ep = endWorldVert.xy / endWorldVert.w;
            t = max(t,line( sp, ep, uv));
        }
    }

    vec3 fc = vec3( 0.0 );


    fc +=  icol* pow(t, 0.2);

    float a=(1.-dot(ouv*0.5,ouv*0.5))*(1.-smoothstep(0.7,1.,length(ouv)));
    fc*=a;
    fragColor = vec4( fc, clamp(pow(t, 0.2),0.,1.)*a );

}

// WARNING this shader trigger Nvidia bugs read https://github.com/godotengine/godot/issues/41109
// one more Nvidia bug/crash by this shader https://github.com/godotengine/godot/issues/41742
void fragment() {
    vec4 col=vec4(0.);
    //in particles instead of mtx[3].xyz-cam_pos can be used VERTEX
    process_verts(col,UV,mtx[3].xyz-cam_pos, col_a.rgb*3.);
    float fade_distance=length(mtx[3].xyz-cam_pos);//float fade_distance=VERTEX.z;
    float fade=clamp(smoothstep(0.25,.5,fade_distance),0.0,1.0);
    ALBEDO = max(col.rgb,col_a.rgb*3.)*fade;
    ALPHA=col.a;
}
