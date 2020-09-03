shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, unshaded;

// based on https://www.vertexshaderart.com/art/TdqvseMQyoJ3ZrjrD // Garden Fireworks - @P_Malin
// do not use my code, this is very bad, exist just for testing/my own learning, use linked original

// geometry generated from triangle particles
// WARNING this is BAD code, I do not want to rework it now. DEPTH is broken on far and angles

uniform vec3 cam_pos=vec3(1.,1.,0.);
uniform float iTime=0.;

const float scale_g = 0.35;
const float height_g = 9.;
const float fRadius_g = 0.01;
const float fShutterSpeed_g = 5.0 / 60.0;
const float fAperture_g = 1.1;
const float fFocalLength_g = 0.15;
const float fExposure_g = 5.;
const float fFloorHeight_const_g = 0.0;

const float HEXAGON_VERTEX_COUNT = (6.0 * 3.0 + 6.0 * 2.0);

vec3 my_normalize3(vec3 v) {
  float len = length(v);
  vec3 ret = vec3(0.);
  if (len == 0.0) ret = vec3(1.0, 0.0, 0.0);
  else ret = v / len;
  return ret;
}

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

float rCross( in vec2 A, in vec2 B) {
  return A.x * B.y - A.y * B.x;
}

void GetTriInfo( in float vertexIndex, out vec2 triVertId, out float triId) {
  float triVertexIndex = mod(vertexIndex, 3.0);

  if (triVertexIndex < 0.5) triVertId = vec2(0.0, 0.0);
  else if (triVertexIndex < 1.5) triVertId = vec2(1.0, 1.0);
  else triVertId = vec2(0.0, 1.0);

  triId = floor(vertexIndex / 3.0);
}

void GetQuadInfo( in float vertexIndex, out vec2 quadVertId, out float quadId) {
  float twoTriVertexIndex = mod(vertexIndex, 6.0);
  float triVertexIndex = mod(vertexIndex, 3.0);

  if (twoTriVertexIndex < 0.5) quadVertId = vec2(0.0, 0.0);
  else if (twoTriVertexIndex < 1.5) quadVertId = vec2(1.0, 0.0);
  else if (twoTriVertexIndex < 2.5) quadVertId = vec2(0.0, 1.0);
  else if (twoTriVertexIndex < 3.5) quadVertId = vec2(1.0, 0.0);
  else if (twoTriVertexIndex < 4.5) quadVertId = vec2(1.0, 1.0);
  else quadVertId = vec2(0.0, 1.0);

  quadId = floor(vertexIndex / 6.0);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float Hash(float p) {
  vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
  p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
  return fract(p2.x * p2.y * 95.4337);
}

const vec3 MOD3 = vec3(.1031, .11369, .13787);
const vec4 MOD4 = vec4(.1031, .11369, .13787, .09987);
vec3 Hash3(float p) {
  vec3 p3 = fract(vec3(p) * MOD3);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

void GetHexagonVertex( in float fAperture, in float fFocalLength, in float fExposure, in float fVertexIndex, in vec2 vOrigin, in vec2 vDir, in float r, in vec3 col0, in vec3 col1,
  out vec2 vPos, out vec3 vColor) {
  float fAngleOffset = fAperture * 0.5;

  if (fVertexIndex < 6.0 * 3.0) {
    float fTriId;
    vec2 vTriVertId;
    GetTriInfo(fVertexIndex, vTriVertId, fTriId);
    float fIndex = fTriId + vTriVertId.x;
    float fAngle = fIndex * radians(360.0) / 6.0;
    float fRadius = vTriVertId.y * r;
    vec2 vPost = vec2(sin(fAngle + fAngleOffset), cos(fAngle + fAngleOffset)) * fRadius;
    float fCurrIndex = fTriId;
    float fCurrAngle = fCurrIndex * radians(360.0) / 6.0;
    vec2 vCurrPos = vec2(sin(fCurrAngle + fAngleOffset), cos(fCurrAngle + fAngleOffset));
    float fNextIndex = fTriId + 1.0;
    float fNextAngle = fNextIndex * radians(360.0) / 6.0;
    vec2 vNextPos = vec2(sin(fNextAngle + fAngleOffset), cos(fNextAngle + fAngleOffset));
    if (rCross(vNextPos - vCurrPos, vDir) >= 0.0) {
      vPost += vDir;
    }
    vPos.xy = vOrigin + vPost;
    vColor.rgb = mix(col0, col1, vTriVertId.y);
  } else {
    float fVertexIndexB = fVertexIndex - 6.0 * 3.0;
    float fQuadId;
    vec2 vQuadVertId;
    GetQuadInfo(fVertexIndexB, vQuadVertId, fQuadId);
    float fEdgeAngle = atan(vDir.x, vDir.y) - fAngleOffset;
    fEdgeAngle = floor(fEdgeAngle * 6.0 / radians(360.0) - 1.0) * radians(360.0) / 6.0;
    if (fQuadId > 0.0) {
      fEdgeAngle += radians(180.0);
    }
    float fRadius = vQuadVertId.y * r;
    vec2 vPost = vec2(sin(fEdgeAngle + fAngleOffset), cos(fEdgeAngle + fAngleOffset)) * fRadius;
    vPost += vDir * vQuadVertId.x;
    vPos.xy = vOrigin + vPost;
    vColor.rgb = mix(col0, col1, vQuadVertId.y);
  }
}

vec3 GetViewPos( in vec3 vPosition, in mat3 mRotation, vec3 vWorldPos) {
  return (vWorldPos - vPosition) * mRotation;
}

vec2 GetScreenPos( in float fAperture, in float fFocalLength, vec3 vViewPos) {
  return vViewPos.xy * fFocalLength * 5.0 / vViewPos.z;
}

vec2 SolveQuadratic(float a, float b, float c) {
  float d = sqrt(b * b - 4.0 * a * c);
  vec2 dV = vec2(d, -d);
  return (-b + dV) / (2.0 * a);
}

vec3 BounceParticle(vec3 vOrigin, vec3 vInitialVel, float fGravity, float fFloorHeight, float fTime) {
  vec3 u = vInitialVel;
  vec3 a = vec3(0.0, fGravity, 0.0);
  vec3 vPos = vOrigin;

  float t = fTime;

  for (int iBounce = 0; iBounce < 3; iBounce++) {
    // When will we hit the ground?
    vec2 q = SolveQuadratic(0.5 * a.y, u.y, -fFloorHeight + vPos.y);
    float tInt = max(q.x, q.y);
    tInt -= 0.0001;

    if (t < tInt) {
      vPos += u * t + 0.5 * a * t * t;
      break;
    } else {
      // Calculate velocity at intersect time
      vec3 v = u + a * tInt;

      // step to intersect time
      vPos += u * tInt + 0.5 * a * tInt * tInt;
      u = v;

      // bounce
      u.y = -u.y * 0.3;
      u.xz *= 0.6;

      t -= tInt;
    }
  }

  return -vPos * scale_g;
}

void Fountain( in float fLightIndex, in vec3 vPos, float fTime, vec3 vCol, float fSpread, out vec3 vWorldPos,
  out float fRadius,
  out vec3 vColor) {
  float fParticleLifetime = 1.5;

  float h = Hash(fLightIndex + 12.0);
  vec3 h3 = Hash3(fLightIndex + 13.0);

  float fAngle = fLightIndex;

  vec3 vInitialVel = (normalize(h3 * 2.0 - 1.0) * fSpread + vec3(0.0, height_g - fSpread * 1.3, 0.0)) * (0.4 + h * 0.4);
  vec3 vOrigin = vPos + vec3(0.0, fFloorHeight_const_g + 0.1, 0.0) + vInitialVel * 0.1;
  vWorldPos = BounceParticle(vOrigin, vInitialVel, -9.81, fFloorHeight_const_g, fTime);

  fRadius = fRadius_g;
  vColor = vCol;
  vColor *= clamp(1.0 - fTime + fParticleLifetime - 1.0, 0.0, 1.0);
}

void GetSequenceInfo(float fSetIndex, float fTime, out float fSequenceSet,
  out float fSequenceIndex,
  out float fSequenceStartTime,
  out float fSequenceSeed,
  out vec3 vSequenceHash,
  out vec3 vCol,
  out vec3 vPos,
  out vec3 vTarget) {

  float fSequenceSetCount = 1.0;
  fSequenceSet = mod(fSetIndex, fSequenceSetCount);

  float sh = Hash(fSequenceSet);
  float fSequenceSetLength = 10.0 + sh * 5.0;

  fSequenceIndex = floor(fTime / fSequenceSetLength);
  fSequenceStartTime = (fSequenceIndex * fSequenceSetLength);

  fSequenceSeed = fSequenceIndex + fSequenceSet * 12.3;
  vSequenceHash = Hash3(fSequenceSeed);

  float ch = Hash(fSequenceSeed * 2.34);
  vCol = vec3(1.0, 0.4, 0.1);

  if (ch < 0.25) {
    vCol = vec3(1.0, 0.08, 0.08);
  } else if (ch < 0.5) {
    vCol = vec3(0.08, 0.08, 1.0);
  } else if (ch < 0.75) {
    vCol = vec3(0.08, 1.0, 0.08);
  }

  vPos = vec3(0.0);
  vPos.xz = vSequenceHash.yz * 6.0 - 3.0;
  vTarget = vPos;
  //vTarget.y = 1.5;

  vTarget = vec3(0.);
  vPos = vec3(0.);
}

void GetFireworkSparkInfo( in float fLightIndex, float fTime, float fDeltaTime, vec3 h3, out vec3 vWorldPos,
  out float fRadius,
  out vec3 vColor) {
  float fParticleLifetime = 1.5;
  float fParticleSpawnTime = (floor((fTime / fParticleLifetime) + h3.x) - h3.x) * fParticleLifetime;
  float fParticleEndTime = fParticleSpawnTime + fParticleLifetime;
  float fParticleGlobalT = fTime - fParticleSpawnTime;
  float fParticleT = mod(fParticleGlobalT, fParticleLifetime) + fDeltaTime;

  float fSequenceSet;
  float fSequenceIndex;
  float fSequenceStartTime;
  float fSequenceSeed;
  vec3 vSequenceHash;
  vec3 vCol;
  vec3 vPos;
  vec3 vTarget;
  GetSequenceInfo(fLightIndex, fParticleSpawnTime, fSequenceSet,
    fSequenceIndex,
    fSequenceStartTime,
    fSequenceSeed,
    vSequenceHash,
    vCol,
    vPos,
    vTarget);
  float fSpread = fract(vSequenceHash.z + vSequenceHash.y) + 1.0;
  Fountain(fLightIndex, vPos, fParticleT, vCol, fSpread, vWorldPos, fRadius, vColor);
}

void GetLightInfo( in float fLightIndex, float fTime, float fDeltaTime, in vec3 vPosition, in vec3 vTarget, in mat3 mRotation, out vec3 vWorldPos,
  out float fRadius,
  out vec3 vColor
) {

  //float h = Hash( fLightIndex );
  vec3 h3 = Hash3(fLightIndex);

  float kHangingLightCount = 32.0;
  float kHangingLightMax = 0.0 + kHangingLightCount;

  float kStarCount = 0.0;
  float kStarMax = kHangingLightMax + kStarCount;

  float kDirtCount = 16.0;
  float kDirtMax = kStarMax + kDirtCount;

  float kStreetLightCount = 64.0;
  float kStreetLightMax = kDirtMax + kStreetLightCount;

  float kGardenLightCount = 16.0;
  float kGardenLightMax = kStreetLightMax + kGardenLightCount;

  {
    GetFireworkSparkInfo(fLightIndex, fTime, fDeltaTime, h3, vWorldPos, fRadius, vColor);
  }

}

void GetBokehVertex( in float fAperture, in float fFocalLength, in float fExposure,
  float fVertexIndex, vec2 vOrigin, vec2 vDir, float fSize, float fCoC, vec3 vCol, out vec2 vPos, out vec3 vColor) {
  float fInnerSize = fSize + fCoC;

  if (fVertexIndex < HEXAGON_VERTEX_COUNT) {
    GetHexagonVertex(fAperture, fFocalLength, fExposure, fVertexIndex, vOrigin, vDir, fInnerSize, vCol, vCol, vPos, vColor);
  } else {
    vPos.xy = vec2(.0);
    vColor.rgb = vec3(.0);
  }
}

vec3 get_vpos(float vertexId, mat4 mworld, mat4 mcam, mat4 rcam, mat4 micam, out vec4 vcol, float time, out float d) {
  float fVertexIndex = vertexId;

  vec3 icam = -mcam[3].xyz;

  vec3 vTarget = vec3(0.);
  vec3 vPosition = icam + mworld[3].xyz;
  mat3 mRotation = mat3(-mcam[0].xyz, -mcam[1].xyz, mcam[2].xyz);

  vec2 vPos;
  vec3 vColor_pos;

  float fBokehIndex = floor(fVertexIndex / HEXAGON_VERTEX_COUNT);

  vec3 vWorldPos;
  float fRadius;
  vec3 vColor;

  GetLightInfo(fBokehIndex, time, 0.0, vPosition,
    vTarget,
    mRotation, vWorldPos, fRadius, vColor);

  vec3 vWorldPos_last;
  float fRadius_last;
  vec3 vColor_last;

  GetLightInfo(fBokehIndex, time, -fShutterSpeed_g, vPosition,
    vTarget,
    mRotation, vWorldPos_last, fRadius_last, vColor_last);

  vec3 vViewPos = GetViewPos(vPosition, mRotation, vWorldPos);

  vec3 vLastViewPos = GetViewPos(vPosition,
    mRotation, vWorldPos_last);

  vec2 vScreenPos = GetScreenPos(fAperture_g, fFocalLength_g, vViewPos);

  vec2 vLastScreenPos = GetScreenPos(fAperture_g, fFocalLength_g, vLastViewPos);

  float fScreenSize = GetScreenPos(fAperture_g, fFocalLength_g, vec3(fRadius, fRadius, vViewPos.z)).x;
  fScreenSize *= scale_g;

  vec2 vOrigin = vScreenPos.xy;
  vec2 vDir = vLastScreenPos.xy - vScreenPos.xy;

  float fCoC = max(0.025 * sin(time * 0.35), 0.);

  vec3 vCol = vColor;

  float fSize = fCoC + fScreenSize;
  vCol *= fScreenSize * fScreenSize * 3.14 / (length(vDir) * fSize + fSize * fSize * 3.14);

  float fBokehVertexIndex = mod(fVertexIndex, HEXAGON_VERTEX_COUNT);
  GetBokehVertex(fAperture_g, fFocalLength_g,
    fExposure_g, fBokehVertexIndex, vOrigin, vDir, fScreenSize, fCoC, vCol, vPos, vColor_pos);

  vec4 ret = vec4(vPos.x, vPos.y, 1. / (vertexId + 1000.), 1);
  float fFinalExposure = fExposure_g / (fAperture_g * fAperture_g);
  vec4 v_color = vec4(0.);
  v_color.rgb = 1.0 - exp2(vColor_pos * -fFinalExposure);
  v_color.rgb = pow(v_color.rgb, vec3(1.0 / 2.2));
  v_color.a = 1.0;
  d = vViewPos.z;
  float fNearClip = .5 * scale_g;

  v_color.a *= smoothstep(0., 0.0175, vViewPos.z - fNearClip);
  if (vViewPos.z <= fNearClip) {
    ret = vec4(0.0);
    v_color = vec4(0.0);
  }
  vcol = v_color;

  return ret.xyz;

}

int triangle_uv(vec2 p) {
  vec2 op = p;
  const float k = 1.73205080756; //sqrt(3.0);
  p.x = abs(p.x) - 1.0;
  p.y = p.y + 1.0 / k;
  int ret = -1;
  if (p.x + k * p.y > 0.0) {
    p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    ret = 1;
  }
  if ((ret == 1) && (op.x < .0) && ((p.y) > 0.)) {
    ret = 1;
  } else
  if ((ret == 1) && (op.x > .0) && ((p.y) > 0.)) {
    ret = 2;
  } else
  if (p.y > 0.) {
    ret = 0;
  } else {
    ret = -1;
  }
  return ret;
}

varying float z_dist;

void vertex() {
  vec3 tvid = VERTEX;
  int tid = triangle_uv((tvid.xz) * 2.);
  COLOR.rgb = VERTEX;
  mat4 wm = WORLD_MATRIX;
  mat4 cm = CAMERA_MATRIX;
  mat4 mtx;

  // bilboard project
  //mtx = mat4(normalize(CAMERA_MATRIX[0]) * length(WORLD_MATRIX[0]), normalize(CAMERA_MATRIX[1]) * length(WORLD_MATRIX[0]), normalize(CAMERA_MATRIX[2]) * length(WORLD_MATRIX[2]), WORLD_MATRIX[3]);

  // lookAt project, comment/uncomment
  mtx = lookAt(cam_pos, WORLD_MATRIX[3].xyz, vec3(0., 1., 0.));
  cm = mtx;
  cm[3].xyz = cam_pos;

  vec4 col;
  float d;
  vec3 ctx = get_vpos(float(INSTANCE_ID * 3 + max(tid, 0)), wm, cm, CAMERA_MATRIX, INV_CAMERA_MATRIX, col, iTime*0.75+11., d);
  VERTEX = (ctx) * ((cm[3].xyz + -wm[3].xyz) / normalize(cm[3].xyz + -wm[3].xyz));
  mtx[3].xyz = WORLD_MATRIX[3].xyz;
  MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mtx;

  z_dist = clamp(1. - (2.5 / d) / 50., 0., 1.);
  z_dist += ctx.z;

  COLOR = col;
}

void fragment() {
  vec3 rd = normalize(((CAMERA_MATRIX) * vec4(normalize(VERTEX), 0.0)).xyz);
  vec3 nor = normalize((CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz);
  ALBEDO = COLOR.rgb * COLOR.a;
  DEPTH = z_dist - .5 * (1. - FRAGCOORD.z) * max(length(FRAGCOORD.xy / VIEWPORT_SIZE.y - 0.5 * VIEWPORT_SIZE.xy / VIEWPORT_SIZE.y), 0.);
  //ALPHA=COLOR.a;
}