shader_type particles;
render_mode keep_data, disable_velocity;

uniform float iTime;
uniform int rid;
uniform float vval;

vec3 inde_x(float idx) {
	ivec3 p=ivec3(0);
	p.x=int(idx)%20-10;
	p.z=(int(idx)/20)%100-0; //% <np>/20
	p.y=0;
	
	vec3 pr=vec3(p);
	
    return pr;
}

vec3 mlpos(float index, out float sz){
	float time=iTime;
	//t=0.;
	//t=mod(t,8.*4.);
	vec3 idx=inde_x(index);
	float sz1=0.;
	if(rid==0){
	sz1=mod(abs(-time*5.+(4.-idx.z)),8.*2.)/(8.*2.);
	float sv=step(mod(abs(-time*5.-8.+(4.-idx.z)),8.*4.),8.*2.);
	sz1=max(sz1*(1.-sv),(.5*(sv)));
	}
	else if(rid==1){
	sz1=mod(abs(-time*5.+sign(idx.x)*(idx.x)+4.-idx.z),8.*2.)/(8.*2.);
	//float sv=step(mod(abs(-t*5.-8.+sign(idx.x)*(idx.x)+4.-idx.z),8.*4.),8.*2.);
	//sz1=max(sz1*(1.-sv),(.5*(sv)));
	}
	else{
	sz1=mod(abs(-time*5.-(4.-idx.x*idx.x)+4.-idx.z),8.*2.)/(8.*2.);
	float sv=step(mod(abs(-time*5.-8.-(4.-idx.x*idx.x)+4.-idx.z),8.*4.),8.*2.);
	sz1=max(sz1*(1.-sv),(.5*(sv)));
	}
	sz=sz1;
	sz=smoothstep(0.,0.5,sz)*smoothstep(1.,0.5,sz);
	//idx.y+=-sz/2.;
	sz+=0.2;
	sz=0.00001+sz*smoothstep(vval+(50.-idx.z)/15.,vval+.5+(50.-idx.z)/15.,iTime);
	return vec3(idx);
}

void vertex() {

	TRANSFORM = EMISSION_TRANSFORM;
	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
	
	float sz=0.0001;
	vec3 tpp=2.*mlpos(float(INDEX),sz);
	vec3 otpp=tpp;
	TRANSFORM[3].xyz=tpp;
	TRANSFORM[0].xyz *= sz;
	TRANSFORM[1].xyz *= sz;
	TRANSFORM[2].xyz *= sz;
}

