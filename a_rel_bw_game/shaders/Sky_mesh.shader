shader_type spatial;
render_mode blend_mix,depth_draw_never,cull_back,unshaded;
uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;

float plane( in vec3 ro, in vec3 rd, vec3 c, vec3 u, vec3 v )
{
	vec3 q = ro - c;
	vec3 n = cross(u,v);
    return -dot(n,q)/dot(rd,n);
}

float nz(in vec2 p){return textureLod(iChannel0, p*.01,0.).x;}
float fbm(in vec2 p, in float d)
{
    mat2 m2 = mat2( vec2(0.80,  0.60), vec2(-0.60,  0.80) );
    float time=iTime*2.;
	d = smoothstep(0.,100.,d);
    p *= .3/(d+0.2);
    float z=2.;
	float rz = 0.;
    p  -= time*0.02;
	for (float i= 1.;i <=5.;i++ )
	{
		rz+= (sin(nz(p)*6.5)*0.5+0.5)*1.25/z; //clouds sin(iTime/10.)*
		z *= 2.1;
		p *= 2.15;
        p += time*0.027*(mod(i,2.)-1.5);
        p *= m2;
	}
    return pow(abs(rz),2.-d);
}

vec3 pldec(vec2 p)
{
    float t = iTime*.13;
    p*=0.25;
    float a = t*.5;
    float s=sin(a), c=cos(a);
    p*=mat2(vec2(c,s),vec2(-s,c));
    p += .21*sin(p.yx*6.+t);
    p = abs(p);
    p*=mat2(vec2(c,s),vec2(-s,c));
    vec3 col =0.5 + 0.5*cos(t*1.4+vec3(p.xy,p.x)*5.+vec3(0,2,4)) + .3*sin(p.x*(1.1+.2*sin(t*.9))*20.+t*.4)+.3;
    
    col.g=0.25*max(0.65*col.r,0.5*col.b);
    col.r=0.5*max(col.r,0.85*col.b);
	col.r=max(col.r,.28-col.g);
    col.b=max(0.65*col.b,.6-col.g);
    return (pow(clamp(col*(1.-length(p*1.6)),vec3(0.),vec3(1.)),vec3(02.5)));
}

vec3 clouds(in vec3 ro, in vec3 rd, in bool wtr)
{   
    vec3 lgt = normalize(vec3(-1.0,0.1,.50));
    float tval=-.2+0.15*iTime;
    //tval=1.;
    lgt = normalize(vec3(sin(tval),-sin(tval),cos(tval)));

    vec3 hor = vec3(0);
    vec3 col1=vec3(0.70,1.0,1.0);
    vec3 col2=vec3(1.3,0.55,0.15);
    vec3 col3=vec3(0.5,0.75,1.);
    
    vec3 scol1=vec3(1.0,0.8,0.7);
    vec3 scol2=vec3(1.0,0.4,0.2);
    
    float hval=min(smoothstep(-0.0,0.15,abs(rd.y)),1.) ;
    float nval=lgt.y/(normalize(vec3(1.)).x);
    float mval2=smoothstep(-.9,-0.2,nval)*smoothstep(-0.8,-.1,nval);
    nval=max(lgt.y/(normalize(vec3(1.)).x),0.);
    
    float sun = clamp(dot(lgt,rd),0.0,1.0 );
    float mval=max(max(nval,sun),0.21);
    float v = 1.0/( 2. * ( 1. + rd.y ) );
	vec2 xy = vec2(rd.x * v, rd.z * v); 
    
    vec3 exc=vec3(0.);
	vec3 col=vec3(0.);
    col2*=mval;
    col3*=mval;
    exc=(pldec(xy));
    scol1=mix(2.*exc,scol1,max(nval,sun));
    
    scol2=mix(scol2*0.5+1.5*exc,scol2,max(nval,sun));
    if (!wtr)
    {
        col += 0.8*scol1*pow(sun,512.0);
        col += 0.2*scol2*pow(sun,32.0);
    }
    else 
    {
		//col3*=(1.-hval);
		col3=1.5*vec3(0.5509,0.42117,0.61725)*hval;
		col3=mix(col3/2.5,col3,nval);
        col += .625*scol1*pow(sun,512.0)*(1.-hval);
        col += 0.13*scol2*pow(sun,32.0)*(1.-hval);
    }
    hor = mix( col1, col2, 0.25+0.75*sun );//*(0.85+0.25*mval2);
    col += 0.4*mix( col3, hor, exp(-(4.+ 2.*(1.-sun))*max(0.0,rd.y-0.05)) );
    col += 0.1*scol2*pow(sun,4.0);
    
	float pt = (90.0-ro.y)/rd.y; 
    vec3 bpos = ro + pt*rd;
    float dist = sqrt(distance(ro,bpos));
    float s2p = distance(bpos,lgt*100.);
    
    float cls = 0.005;
    float bz = 0.;
    float tot = bz;
    float ds = 2.;
    if (!wtr){
    bz=fbm(bpos.xz*cls,dist);
    tot=bz;
    tot = smoothstep(0.,1.15,tot);
    
    for (float i=0.;i<=3.;i++)
    {

        vec3 pp = bpos + ds*lgt;
        float vl = fbm(pp.xz*cls,dist);
        vl = smoothstep(0.,1.15,vl);
        tot += vl;
        ds *= .14*dist;
    }}
    bz*=hval;
    tot*=hval;
    
    col = mix(col,vec3(.5)*0.2*nval,pow(bz,1.5));
    tot = smoothstep(-7.5,-0.,1.-tot);
    vec3 sccol = mix(col3*vec3(0.1,0.1,0.2),scol1*vec3(.2,0.,0.1),smoothstep(0.,900.,s2p)); 
    col = mix(col,sccol,1.-tot)*1.6;
    vec3 sncol = mix(scol2*1.75,scol2*1.25,smoothstep(0.,1200.,s2p)); //ночь
    float sd = pow(sun,10.)+.7;
    col += sncol*bz*bz*bz*tot*tot*tot*sd;
    if (!wtr)col+=(1.-bz)*01.15*exc*(1.-mval);
    else col+=01.15*exc*(1.-mval)*(1.-hval);
	
	col=mix(col*col,col/1.5+col*col,nval);
	
    return col;
}

vec3 clouds_col(vec3 ro, vec3 rd){
    float pln = plane(ro, rd, vec3(0.,-4.,0), vec3(1.,0.,0.), vec3(0.0,.0,1.0));
    bool wtr = false;
    vec3 bm = vec3(0);
    if (pln < 500. && pln > 0.)
    {
        vec3 n = vec3(0,1,0);
        rd = reflect(rd,n);
        wtr = true;
    }
    vec3 clo = clouds(ro, rd, wtr);
    return clo;
}


void vertex() {
}

void fragment() {
	vec3 cam=((CAMERA_MATRIX*vec4(1.0)).xyz);
	vec3 rd=normalize(((CAMERA_MATRIX*vec4(normalize(-VERTEX),0.0)).xyz));
	ALBEDO = clouds_col(cam,reflect(rd,vec3(0.,-1.,0.)));
	ALPHA=1.;
}
