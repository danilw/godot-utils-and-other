shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,unshaded;


void translate(inout mat4 m, vec3 d){
	m[3][0] = d.x;
	m[3][1] = d.y;
	m[3][2] = d.z;
	
	m[3].xyz=d; //does not matter, both does not work
}

void fake_vertex(inout mat4 mtx, inout mat4 tmtx) {

	mtx=mat4(vec4(1.),vec4(1.),vec4(1.),vec4(1.));
	tmtx=mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.));
	

	tmtx=mat4(mtx[0].xyzw,mtx[1].xyzw,mtx[2].xyzw,mtx[3].xyzw); //both work same
	tmtx=mtx; //both work same
	// at some point it also may not work same, in this shader it same
	
	vec3 a=vec3(1.,0.,0.);
	vec3 b=vec3(0.,1.,0.);
	
	//bug
	translate(tmtx,a); //this do nothing, and ruin tmtx value in more complex logic when tmtx used outside of Vertex function
	//tmtx[3].xyz=a; //fix
	
	//mat4 tm=tmtx;translate(tm,a);tmtx=tm; //do nothing
	
	mtx[3].xyz=b;
	
	//tmtx=mtx; //does work
	
}

void fragment() {
	mat4 mtx;
	mat4 tmtx;
	fake_vertex(mtx, tmtx);
	vec4 col=vec4(0.);
	if(UV.x<0.5)ALBEDO = mtx[3].xyz;
	else ALBEDO = tmtx[3].xyz;
}
