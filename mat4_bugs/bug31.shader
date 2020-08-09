shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,unshaded;

varying mat4 mtx;
varying mat4 tmtx;

// this is only small part of "comples logic" that ruined because bugs
// every function is valid, should be no error on function-side

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
	vec3 right = cross(my_normalize3(tup), forward); 
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
	
	//camToWorld=mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.,0.,1.,0.)); //not same result with next line
	//return mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.,0.,1.,0.));
	return camToWorld; 
}

void translate(inout mat4 m, vec3 d){
	m[3][0] = d.x;
    m[3][1] = d.y;
    m[3][2] = d.z;
	
	m[3].xyz=d; //does not matter, both does not work
}

void vertex() {
	mtx=mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.,0.,1.,0.));//same as next line
	//mtx=lookAt(vec3(0.,0.,1.),WORLD_MATRIX[3].xyz,vec3(0.,1.,0.));
	//tmtx=mtx;
	tmtx=WORLD_MATRIX; // this fix translate function line 64
	
	
	vec3 a=vec3(1.,WORLD_MATRIX[3].y,0.);
	vec3 b=vec3(0.,1.,0.);
	
	translate(tmtx,a);
	
	//tmtx[3].xyz=a; fix work if comment line 70
	
	mtx[3].xyz=b;
	
	//tmtx=mtx; //does not work
	//tmtx[3].xyz=mtx[3].xyz; //does work
	
	mtx=WORLD_MATRIX; //comment this will ruin line 64 translate function
}

void fragment() {
	vec4 col=vec4(0.);
	if(UV.y<0.5){
		if(UV.x<0.5)ALBEDO=vec3(abs(mtx[3].y),0.,0.);
		else ALBEDO=vec3(abs(tmtx[3].y),0.,0.);
	}
	else{
		if(UV.x<0.5)ALBEDO = mtx[3].xyz;
		else ALBEDO = tmtx[3].xyz;
	}
}
