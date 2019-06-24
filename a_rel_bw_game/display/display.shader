shader_type canvas_item;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform float iTime;
uniform float conf_click;
uniform int iFrame;
uniform bool minif;
uniform bool minif2;
uniform float play_click;
uniform bool ppoff;
uniform float sval;
uniform float ssval;
uniform float msval;
uniform bool psval;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
/*
float noise( in vec3 x )
{
    x*=0.01;
	float  z = x.z*256.0;
	vec2 offz = vec2(0.317,0.123);
	vec2 uv1 = x.xy + offz*floor(z); 
	vec2 uv2 = uv1  + offz;
	return mix(textureLod( iChannel1, uv1 ,0.0).x,textureLod( iChannel1, uv2 ,0.0).x,fract(z));
}

float fbm2(in vec3 p, float iTime)
{
	float f = 0.;p*=8.;
	f += .850000 * noise(1. * (p+vec3(0.,0.,iTime*0.275)));
	f += .25000 * noise(2. * (p+vec3(0.,0.,iTime*0.275)));
	f += .12500 * noise(4. * (p+vec3(0.,0.,iTime*0.275)));
	f += .06250 * noise(8. * (p+vec3(0.,0.,iTime*0.275)));
	return f;
}
*/

/*
float n2D( in vec2 x ){return textureLod( iChannel1, x/256. ,0.0).x;}
float fbm(vec2 p){ return n2D(p)*.533 + n2D(p*2.)*.267 + n2D(p*4.)*.133 + n2D(p*8.)*.067; }
*/

vec4 add_ui(vec2 uv,vec2 res){
	float grid = 0.5-max(abs(mod(uv.x*64.0,1.0)-0.5), abs(mod(uv.y*64.0,1.0)-0.5));
    grid=0.4+smoothstep(0.0,64.0 / 600.,grid)*0.65;
	if(!(uv.x<res.x/2.-0.14)){
		uv.x-=res.x/2.-0.05;
		float ea=smoothstep(0.38,0.36,abs(uv.y));
		float eaa=ea*smoothstep(0.04,0.03,abs(uv.x+0.004));
		ea*=smoothstep(0.132,0.115, length(vec2(uv.x,uv.y*0.35)));
		ea*=smoothstep(0.05,0.04, abs(uv.x));
		uv*=4.;
	    uv.y=-uv.y;
	    vec3 wave_color = vec3(0.0);
		uv.x += (-0.035 )*2.;
		float aval=smoothstep(0.38,0.36,-uv.y/4.+(1.-ssval)*(1.-0.28));
		if(ppoff)return vec4(vec3(0.05,0.3,0.9)*vec3(0.35+(rand(uv) - .5)*.07),0.85*aval*eaa*smoothstep(0.07,0.05,abs(uv.x+0.08)));
	    for(float i = 0.0; i < 4.0; i++) {
			uv.x += (0.035 );
			float wave_width = (1.0 / (100.0 * max(0.0001,abs(uv.x))));
	        
			wave_color += vec3(wave_width * uv.y*2., wave_width * 0.734* (max(uv.y,0.)+01.5) , 01.8*wave_width *(-uv.y+0.5)).bgr;
		}
		wave_color=ea*clamp(wave_color,vec3(0.),vec3(10.));
		if(psval){
			wave_color=wave_color.brr;
		}
	    //wave_color.rgb=mix(wave_color.rgb,pow(clamp(wave_color.rgb*0.5,vec3(0.),vec3(2.)),vec3(2.)),0.5+0.5*sin(iTime));
		
	    float a=dot(wave_color*0.6,wave_color);
		a=clamp(a,0.,1.);
		float aval2=smoothstep(0.55,0.36,-uv.y/4.+(1.-ssval)*(1.-0.28));
	    wave_color.rgb*=aval;
		a=0.5*a+0.5*a*aval2;
	    vec4 rtx = vec4(wave_color,a)*grid+0.*(1.-a)*0.25*grid*eaa;
		rtx.rgb=mix(rtx.brg,rtx.rgb,ssval);
		rtx.a=min(rtx.a,1.)*0.358;
		//rtx.rgb=pow(rtx.rgb,vec3(2.));
		return rtx;
	}
	if(!(uv.x<-res.x/2.+0.14))return vec4(0.);
    uv.x+=res.x/2.-0.05;
    float ea=smoothstep(0.38,0.36,abs(uv.y));
	float eaa=ea*smoothstep(0.027,0.025,abs(uv.x-0.004));
	ea*=smoothstep(0.132,0.115, length(vec2(uv.x,uv.y*0.35)));
	ea*=smoothstep(0.05,0.029, abs(uv.x-0.004));
    uv*=4.;
    uv.y=-uv.y;
	uv.x+=-0.11;
	float aval=smoothstep(0.38,0.36,-uv.y/4.+(1.-sval)*(1.-0.28));
	if(ppoff)return vec4(vec3(0.9,0.1,0.05)*vec3(0.35+(rand(uv) - .5)*.07),0.85*aval*eaa*smoothstep(0.07,0.05,abs(uv.x+0.08)));
    vec3 wave_color = vec3(0.0);
    for(float i = 0.0; i < 6.0; i++) {
		uv.x += (0.025)*(smoothstep(0.4*4.,0.82,abs(uv.y)));
		float wave_width = (1.0 / (180.0 * max(0.0001,abs(uv.x))));
        
		wave_color += vec3(wave_width * uv.y*3., wave_width * 0.34* (max(uv.y,0.)+02.) , 01.8*wave_width *(-uv.y+01.5));
	}
	wave_color=ea*clamp(wave_color,vec3(0.),vec3(10.));
	wave_color=mix(wave_color,vec3(dot(wave_color,wave_color),0.,0.),smoothstep(0.,0.18,msval));
    //wave_color.rgb=mix(wave_color.rgb,pow(clamp(wave_color.rgb*0.5,vec3(0.),vec3(2.)),vec3(2.)),0.5+0.5*sin(iTime));
	
    float a=dot(wave_color*0.6,wave_color);
	a=clamp(a,0.,1.);
	float aval2=smoothstep(0.52,0.36,-uv.y/4.+(1.-sval)*(1.-0.28));
    wave_color.rgb*=aval;
	a=0.5*a+0.5*a*aval2;
    vec4 rtx= vec4(wave_color,a)*grid+(1.-a)*0.25*grid*eaa;
	rtx.a=min(rtx.a,1.)*0.358;
	//rtx.rgb=pow(rtx.rgb,vec3(2.));
	return rtx;
}

float get_pause_anim_timer(){return smoothstep(1.5,3.0,iTime);}
float get_pause_anim_timer2(){return smoothstep(.75,2.0,iTime);}
float get_pause_anim_timer3(){return smoothstep(0.30,.950,iTime);}
float get_pause_anim_timer4(){return smoothstep(2.8,4.30,iTime);}

vec3 eff1(vec2 uv, vec4 col, vec4 c1, vec2 res, float px, float vignetteAmt){
	vec3 bg = col.rgb;
	if(minif)c1.rgb=mix(vec3(0.5509,0.42117,0.61725),c1.rgb,1.-smoothstep(conf_click+0.5,conf_click+2.,iTime));
	col=clamp(col,vec4(0.),vec4(10.));
    bg=mix(c1.rgb,bg,col.a);
	if(ppoff){
		vec4 tcx=add_ui(uv,res);
		bg=mix(bg,tcx.rgb,tcx.a);
		return bg;
		}
	float eval=1.;
    /*float ns = fbm(uv*10. + 17.3);
	ns = mix(ns, sin(ns*32. - cos(ns*34.)), .125);
	eval *= max(ns, 0.)*.24 + .8;*/
	
	/*
	vec3 ro = vec3( -0., 0., 1.);
	vec3 cw = normalize( ro );
	vec3 cu = normalize( cross(cw,vec3(0.,1.,0.)) );
	vec3 cv = normalize( cross(cu,cw) );

	vec3 rd = normalize( uv.x*cu + uv.y*cv + 1.5*cw );
	ns=fbm2(rd,iTime*3.);
    eval *= max(ns, 0.)*.24 + .8;*/
    
    float pat = 0.; //clamp(sin((uv.x - uv.y)*( 600./1.5)) + .5, 0., 1.);
	float dv=0.;
	float tv=0.;
	if((minif2)&&(!minif)){
		float imid=floor(abs((uv*mat2(vec2(cos(-.85), -sin(-.85)), vec2(sin(-.85), cos(-.85)))).y/0.015));
		float itt=6.*smoothstep(play_click,play_click+6.,iTime);
		tv=smoothstep(0.,6.,itt);
		dv=1.-step(1.8*smoothstep(0.+imid/30.,2.+imid/20.,0.75*itt),abs(uv*mat2(vec2(cos(-.85), -sin(-.85)), vec2(sin(-.85), cos(-.85)))).x);
		pat=max(step(mod((uv*mat2(vec2(cos(-.85), -sin(-.85)), vec2(sin(-.85), cos(-.85)))).y,0.015),0.0075),dv);
	}
	else{
		pat=step(mod((uv*mat2(vec2(cos(-.85), -sin(-.85)), vec2(sin(-.85), cos(-.85)))).y,0.015),0.0075);
	}
    float rnd = rand(uv);
    if(rnd>.5) pat *= .6; 
    else pat *= 1.4;
	pat=mix(pat,1.,dv);
	eval *= pat*0.3+0.75;
    //eval *= pat*((1.-vignetteAmt)*0.2+.1) + (vignetteAmt*0.2+.75);
	
	vec2 b = res - .05-0.92*(1.-get_pause_anim_timer2());
    vec2 q = abs(uv*2.);
    float bord = max(q.x - b.x, q.y - b.y);
    float qb=-bord;
	float tbp=min(1.-smoothstep(0.,px,qb),1.-get_pause_anim_timer());
    bg=mix(bg,vec3(0.),tbp);
	
	if(!minif)bord = max(bord, -(bord + .11));
    if(minif)eval=max(eval*(1.-smoothstep(0.,px,qb+0.01)),smoothstep(0.,px,qb));
	
	float ntva=min(q.x - b.x + .22+(1.*(1.-get_pause_anim_timer4()))*res.x, q.y - b.y + (.22+1.*(1.-get_pause_anim_timer4())));
    bord = max(bord, -ntva);
    bord*=get_pause_anim_timer3();
    bg = mix(bg, vec3(0), (1. - smoothstep(0., px*12., bord ))*.35);
    bg = mix(bg, vec3(0), (1. - smoothstep(0., px, bord))*.27);
    bg = mix(bg, bg*2.2, (1. - smoothstep(0., px, bord*( smoothstep(0., px, bord + .035)) + .01)));
	bg=mix(bg*eval,bg+(rnd - .5)*.07,step(.9,col.a));
    bg *= vignetteAmt;
	vec4 tcx=add_ui(uv,res);
	tcx=mix(tcx,vec4(0.),tbp);
	if((minif2)&&(!minif)){
	tcx=mix(tcx*vignetteAmt,tcx,1.-smoothstep(play_click+6.,play_click+2.,iTime));}
	else{
	tcx*=vignetteAmt;
	}
	tcx*=smoothstep(0., px*12., -ntva );
    bg=mix(bg,tcx.rgb,tcx.a);
	//bg = bg / 2. + bg*bg;
	//bg = mix(bg.xzy, bg, .75);  
	bg = mix(bg.xzy, bg, max(tv,uv.y*.3 + .65));
	return bg;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution, sampler2D iChannel0)
{
	vec2 res = (iResolution.xy / iResolution.y);
    vec2 uv = (fragCoord.xy) / iResolution.y - res / 2.0;
	vec2 ouv=fragCoord.xy/iResolution.xy;
	vec4 acol=texture(iChannel0,ouv);
	vec4 bcol=texture(iChannel2,ouv);//bcol=sqrt(bcol);
    vec3 col = vec3(0.);
	float vignetteAmt = 1. - dot((ouv-0.5) * 01.265, (ouv-0.5) * 01.265);
	col=eff1(uv,acol,bcol,res,1./iResolution.y,vignetteAmt);
	
	
    fragColor = vec4(col,1.0);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution,TEXTURE);
}
