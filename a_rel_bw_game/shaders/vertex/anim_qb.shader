shader_type particles;
render_mode keep_data, disable_velocity;

uniform float iTime:hint_range(0,10);

vec3 inde_x(float idx) {
	ivec3 p=ivec3(0);
    p.x = int(idx)%8;
	p.y = (int(idx)/8)%8;
	p.z=2*(((int(idx)/8)/8)%4);
	vec3 pr=vec3(p);
	if(p.z==0){pr.z*=2.;pr=pr-vec3(4.-1.,3.5,4.);}
	else
	if(p.z==2){pr.xyz=pr.zxy;pr=pr-vec3(6.5-0.5,3.5,3.5+0.5);}
	else
	if(p.z==6){pr.xyz=pr.zyx;pr.x*=1.;pr=pr-vec3(2.5-0.5,3.5,3.5-.5);}
	else {pr.z*=2.;pr=pr-vec3(4.,3.5,4.);}
    return pr;
}

vec3 mlpos(float index, out float sz){
	float t=iTime;
	vec3 idx=inde_x(index);
	float sz1=mod(abs(t*5.+(4.-idx.z)+4.-idx.y),8.*2.)/(8.*2.);
	//float sz1=mod(abs(t*5.+(4.-idx.z*idx.x)+4.-idx.y),8.*2.)/(8.*2.);
	sz=sz1;
	sz=0.0001+smoothstep(0.,0.5,sz)*smoothstep(1.,0.5,sz);
	//sz=1.;
	return vec3(idx);
}

void vertex() {

	TRANSFORM = EMISSION_TRANSFORM;
	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
	
	float sz=0.0001;
	TRANSFORM[3].xyz=0.3*mlpos(float(INDEX),sz);
	TRANSFORM[0].xyz *= sz;
	TRANSFORM[1].xyz *= sz;
	TRANSFORM[2].xyz *= sz;
}

