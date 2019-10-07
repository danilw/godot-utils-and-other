shader_type canvas_item;
//render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform int iFrame1;
uniform sampler2D iChannel0:hint_black_albedo;
uniform sampler2D iChannel1:hint_black_albedo;
uniform sampler2D iChannel2:hint_black_albedo;
uniform sampler2D iChannel3:hint_black_albedo;

uniform sampler2D box_array:hint_black_albedo;
uniform sampler2D circle_array:hint_black_albedo;
uniform sampler2D line_array:hint_black_albedo;
uniform sampler2D text_array:hint_black_albedo;
uniform sampler2D tri_array:hint_black_albedo;

// using https://www.shadertoy.com/view/lldcDf
// using https://www.shadertoy.com/view/4s3XDn


float line(vec2 p, vec2 a, vec2 b)
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

//These functions are re-used by multiple letters
float _u(vec2 uv, float w, float v) {
    return length(vec2(
                abs(length(vec2(uv.x,
                                max(0.0,-(.4-v)-uv.y) ))-w)
               ,max(0.,uv.y-.4)));
}
float _i(vec2 uv) {
    return length(vec2(uv.x,max(0.,abs(uv.y)-.4)));
}
float _j(vec2 uv) {
    uv.x+=.2;
    uv.y+=.55;
    float x = 0.;
    if(uv.x>0.&&uv.y<0.)x=abs(length(uv)-.25);
    else x=min(length(uv+vec2(0.,.25)),
                    length(vec2(uv.x-.25,max(0.,abs(uv.y-.475)-.475))));
    return x;
}
float _l(vec2 uv) {
    uv.y -= .2;
    return length(vec2(uv.x,max(0.,abs(uv.y)-.6)));
}
float _o(vec2 uv) {
    return abs(length(vec2(uv.x,max(0.,abs(uv.y)-.15)))-.25);
}

// Here is the alphabet
float aa(vec2 uv) {
    uv = -uv;
    float x = abs(length(vec2(max(0.,abs(uv.x)-.05),uv.y-.2))-.2);
    x = min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y-.2)-.2))));
    float b=0.;
    if(uv.x<0.){if(uv.y<0.)b=_o(uv);else b=length(vec2(uv.x-.22734,uv.y+.254));}
    else if(atan(uv.x,uv.y+0.15)>2.)b=_o(uv);else b=length(vec2(uv.x-.22734,uv.y+.254));
    return min(x,b);
}
float bb(vec2 uv) {
    float x = _o(uv);
    uv.x += .25;
    return min(x,_l(uv));
}
float cc(vec2 uv) {
    float x = _o(uv);
    uv.y= abs(uv.y);
    if(uv.x<0.||atan(uv.x,uv.y-0.15)<1.14)
        return x;
    else
        return min(length(vec2(uv.x+.25,max(0.0,abs(uv.y)-.15))),//makes df right 
                        length(uv+vec2(-.22734,-.254)));
}
float dd(vec2 uv) {
    uv.x *= -1.;
    return bb(uv);
}
float ee(vec2 uv) {
    float x = _o(uv);
    float b=0.;
    if(uv.x<0.||uv.y>.05||atan(uv.x,uv.y+0.15)>2.)b=x;
    else b=length(vec2(uv.x-.22734,uv.y+.254));
    return min(b,
               length(vec2(max(0.,abs(uv.x)-.25),uv.y-.05)));
}
float ff(vec2 uv) {
    uv.x *= -1.;
    uv.x += .05;
    float x = _j(vec2(uv.x,-uv.y));
    uv.y -= .4;
    x = min(x,length(vec2(max(0.,abs(uv.x-.05)-.25),uv.y)));
    return x;
}
float gg(vec2 uv) {
    float x = _o(uv);
    float b=0.;
    if(uv.x>0.||atan(uv.x,uv.y+.6)<-2.)b=_u(uv,0.25,-0.2);
    else b=length(uv+vec2(.23,.7));
    return min(x,b);
}
float hh(vec2 uv) {
    uv.y *= -1.;
    float x = _u(uv,.25,.25);
    uv.x += .25;
    uv.y *= -1.;
    return min(x,_l(uv));
}
float ii(vec2 uv) {
    return min(_i(uv),length(vec2(uv.x,uv.y-.6)));
}
float jj(vec2 uv) {
    uv.x+=.05;
    return min(_j(uv),length(vec2(uv.x-.05,uv.y-.6)));
}
float kk(vec2 uv) {
    float x = line(uv,vec2(-.25,-.1), vec2(0.25,0.4));
    x = min(x,line(uv,vec2(-.15,.0), vec2(0.25,-0.4)));
    uv.x+=.25;
    return min(x,_l(uv));
}
float ll(vec2 uv) {
    return _l(uv);
}
float mm(vec2 uv) {
    //uv.x *= 1.4;
    uv.y *= -1.;
    uv.x-=.175;
    float x = _u(uv,.175,.175);
    uv.x+=.35;
    x = min(x,_u(uv,.175,.175));
    uv.x+=.175;
    return min(x,_i(uv));
}
float nn(vec2 uv) {
    uv.y *= -1.;
    float x = _u(uv,.25,.25);
    uv.x+=.25;
    return min(x,_i(uv));
}
float oo(vec2 uv) {
    return _o(uv);
}
float pp(vec2 uv) {
    float x = _o(uv);
    uv.x += .25;
    uv.y += .4;
    return min(x,_l(uv));
}
float qq(vec2 uv) {
    uv.x = -uv.x;
    return pp(uv);
}
float rr(vec2 uv) {
    uv.x -= .05;
    float x =0.;
    if(atan(uv.x,uv.y-0.15)<1.14&&uv.y>0.)x=_o(uv);
    else x=length(vec2(uv.x-.22734,uv.y-.254));
    
    uv.x+=.25;
    return min(x,_i(uv));
}
float ss(vec2 uv) {
    if (uv.y <.225-uv.x*.5 && uv.x>0. || uv.y<-.225-uv.x*.5)
        uv = -uv;
    float a = abs(length(vec2(max(0.,abs(uv.x)-.05),uv.y-.2))-.2);
    float b = length(vec2(uv.x-.231505,uv.y-.284));
    float x = 0.;
    if(atan(uv.x-.05,uv.y-0.2)<1.14)x=a;else x=b;
    return x;
}
float tt(vec2 uv) {
    uv.x *= -1.;
    uv.y -= .4;
    uv.x += .05;
    float x = min(_j(uv),length(vec2(max(0.,abs(uv.x-.05)-.25),uv.y)));
    return x;
}
float uu(vec2 uv) {
    return _u(uv,.25,.25);
}
float vv(vec2 uv) {
    uv.x=abs(uv.x);
    return line(uv,vec2(0.25,0.4), vec2(0.,-0.4));
}
float ww(vec2 uv) {
    uv.x=abs(uv.x);
    return min(line(uv,vec2(0.3,0.4), vec2(.2,-0.4)),
               line(uv,vec2(0.2,-0.4), vec2(0.,0.1)));
}
float xx(vec2 uv) {
    uv=abs(uv);
    return line(uv,vec2(0.,0.), vec2(.3,0.4));
}
float yy(vec2 uv) {
    return min(line(uv,vec2(.0,-.2), vec2(-.3,0.4)),
               line(uv,vec2(.3,.4), vec2(-.3,-0.8)));
}
float zz(vec2 uv) {
    float l = line(uv,vec2(0.25,0.4), vec2(-0.25,-0.4));
    uv.y=abs(uv.y);
    float x = length(vec2(max(0.,abs(uv.x)-.25),uv.y-.4));
    return min(x,l);
}

// Capitals
float AA(vec2 uv) {
    float x = length(vec2(
                abs(length(vec2(uv.x,
                                max(0.0,uv.y-.35) ))-0.25)
               ,min(0.,uv.y+.4)));
    return min(x,length(vec2(max(0.,abs(uv.x)-.25),uv.y-.1) ));
}

float BB(vec2 uv) {
    uv.y -=.1;
    uv.y = abs(uv.y);
    float x = length(vec2(
                abs(length(vec2(max(0.0,uv.x),
                                 uv.y-.25))-0.25)
               ,min(0.,uv.x+.25)));
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y)-.5)) ));
}
float CC(vec2 uv) {
    float x = abs(length(vec2(uv.x,max(0.,abs(uv.y-.1)-.25)))-.25);
    uv.y -= .1;
    uv.y= abs(uv.y);
    if(uv.x<0.||atan(uv.x,uv.y-0.25)<1.14) return x;
    else return min(length(vec2(uv.x+.25,max(0.0,abs(uv.y)-.25))),//makes df right 
                        length(uv+vec2(-.22734,-.354)));
}
float DD(vec2 uv) {
    uv.y -=.1;
    //uv.y = abs(uv.y);
    float x = length(vec2(
                abs(length(vec2(max(0.0,uv.x),
                                max(0.0,abs(uv.y)-.25)))-0.25)
               ,min(0.,uv.x+.25)));
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y)-.5)) ));
}
float EE(vec2 uv) {
    uv.y -=.1;
    uv.y = abs(uv.y);
    float x = min(length(vec2(max(0.,abs(uv.x)-.25),uv.y)),
                  length(vec2(max(0.,abs(uv.x)-.25),uv.y-.5)));
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y)-.5))));
}
float FF(vec2 uv) {
    uv.y -=.1;
    float x = min(length(vec2(max(0.,abs(uv.x)-.25),uv.y)),
                  length(vec2(max(0.,abs(uv.x)-.25),uv.y-.5)));
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y)-.5))));
}
float GG(vec2 uv) {
    float x = abs(length(vec2(uv.x,max(0.,abs(uv.y-.1)-.25)))-.25);
    uv.y -= .1;
    float a = atan(uv.x,max(0.,abs(uv.y)-0.25));
    if(uv.x<0.||a<1.14 || a>3.) x=x;
    else x=min(length(vec2(uv.x+.25,max(0.0,abs(uv.y)-.25))),//makes df right 
                        length(uv+vec2(-.22734,-.354)));
    x = min(x,line(uv,vec2(.22734,-.1),vec2(.22734,-.354)));
    return min(x,line(uv,vec2(.22734,-.1),vec2(.05,-.1)));
}
float HH(vec2 uv) {
    uv.y -=.1;
    uv.x = abs(uv.x);
    float x = length(vec2(max(0.,abs(uv.x)-.25),uv.y));
    return min(x,length(vec2(uv.x-.25,max(0.,abs(uv.y)-.5))));
}
float II(vec2 uv) {
    uv.y -= .1;
    float x = length(vec2(uv.x,max(0.,abs(uv.y)-.5)));
    uv.y = abs(uv.y);
    return min(x,length(vec2(max(0.,abs(uv.x)-.1),uv.y-.5)));
}
float JJ(vec2 uv) {
    uv.x += .125;
    float x = length(vec2(
                abs(length(vec2(uv.x,
                                min(0.0,uv.y+.15) ))-0.25)
               ,max(0.,max(-uv.x,uv.y-.6))));
    return min(x,length(vec2(max(0.,abs(uv.x-.125)-.125),uv.y-.6)));
}
float KK(vec2 uv) {
    float x = line(uv,vec2(-.25,-.1), vec2(0.25,0.6));
    x = min(x,line(uv,vec2(-.1, .1), vec2(0.25,-0.4)));
//    uv.x+=.25;
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y-.1)-.5))));
}
float LL(vec2 uv) {
    uv.y -=.1;
    float x = length(vec2(max(0.,abs(uv.x)-.2),uv.y+.5));
    return min(x,length(vec2(uv.x+.2,max(0.,abs(uv.y)-.5))));
}
float MM(vec2 uv) {
    uv.y-=.1;
    float x = min(length(vec2(uv.x-.35,max(0.,abs(uv.y)-.5))),
                  line(uv,vec2(-.35,.5),vec2(.0,-.1)));
    x = min(x,line(uv,vec2(.0,-.1),vec2(.35,.5)));
    return min(x,length(vec2(uv.x+.35,max(0.,abs(uv.y)-.5))));
}
float NN(vec2 uv) {
    uv.y-=.1;
    float x = min(length(vec2(uv.x-.25,max(0.,abs(uv.y)-.5))),
                  line(uv,vec2(-.25,.5),vec2(.25,-.5)));
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y)-.5))));
}
float OO(vec2 uv) {
    return abs(length(vec2(uv.x,max(0.,abs(uv.y-.1)-.25)))-.25);
}
float PP(vec2 uv) {
    float x = length(vec2(
                abs(length(vec2(max(0.0,uv.x),
                                 uv.y-.35))-0.25)
               ,min(0.,uv.x+.25)));
    return min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y-.1)-.5)) ));
}
float QQ(vec2 uv) {
    float x = abs(length(vec2(uv.x,max(0.,abs(uv.y-.1)-.25)))-.25);
    uv.y += .3;
    uv.x -= .2;
    return min(x,length(vec2(abs(uv.x+uv.y),max(0.,abs(uv.x-uv.y)-.2)))/sqrt(2.));
}
float RR(vec2 uv) {
    float x = length(vec2(
                abs(length(vec2(max(0.0,uv.x),
                                 uv.y-.35))-0.25)
               ,min(0.,uv.x+.25)));
    x = min(x,length(vec2(uv.x+.25,max(0.,abs(uv.y-.1)-.5)) ));
    return min(x,line(uv,vec2(0.0,0.1),vec2(0.25,-0.4)));
}
float SS(vec2 uv) {
    uv.y -= .1;
    if (uv.y <.275-uv.x*.5 && uv.x>0. || uv.y<-.275-uv.x*.5)
        uv = -uv;
    float a = abs(length(vec2(max(0.,abs(uv.x)),uv.y-.25))-.25);
    float b = length(vec2(uv.x-.236,uv.y-.332));
    float x = 0.;
    if(atan(uv.x-.05,uv.y-0.25)<1.14)x=a;else x=b;
    return x;
}
float TT(vec2 uv) {
    uv.y -= .1;
    float x = length(vec2(uv.x,max(0.,abs(uv.y)-.5)));
    return min(x,length(vec2(max(0.,abs(uv.x)-.25),uv.y-.5)));
}
float UU(vec2 uv) {
    float x = length(vec2(
                abs(length(vec2(uv.x,
                                min(0.0,uv.y+.15) ))-0.25)
               ,max(0.,uv.y-.6)));
    return x;
}
float VV(vec2 uv) {
    uv.x=abs(uv.x);
    return line(uv,vec2(0.25,0.6), vec2(0.,-0.4));
}
float WW(vec2 uv) {
    uv.x=abs(uv.x);
    return min(line(uv,vec2(0.3,0.6), vec2(.2,-0.4)),
               line(uv,vec2(0.2,-0.4), vec2(0.,0.2)));
}
float XX(vec2 uv) {
    uv.y -= .1;
    uv=abs(uv);
    return line(uv,vec2(0.,0.), vec2(.3,0.5));
}
float YY(vec2 uv) {
    return min(min(line(uv,vec2(.0, .1), vec2(-.3, 0.6)),
                   line(uv,vec2(.0, .1), vec2( .3, 0.6))),
                   length(vec2(uv.x,max(0.,abs(uv.y+.15)-.25))));
}
float ZZ(vec2 uv) {
    float l = line(uv,vec2(0.25,0.6), vec2(-0.25,-0.4));
    uv.y-=.1;
    uv.y=abs(uv.y);
    float x = length(vec2(max(0.,abs(uv.x)-.25),uv.y-.5));
    return min(x,l);
}

//Numbers
float _11(vec2 uv) {
    return min(min(
             line(uv,vec2(-0.2,0.45),vec2(0.,0.6)),
             length(vec2(uv.x,max(0.,abs(uv.y-.1)-.5)))),
             length(vec2(max(0.,abs(uv.x)-.2),uv.y+.4)));
             
}
float _22(vec2 uv) {
    float x = min(line(uv,vec2(0.185,0.17),vec2(-.25,-.4)),
                  length(vec2(max(0.,abs(uv.x)-.25),uv.y+.4)));
    uv.y-=.35;
    uv.x += 0.025;
    float b=0.;
    if(abs(atan(uv.x,uv.y)-0.63)<1.64)b=abs(length(uv)-.275);
    else b=length(uv+vec2(.23,-.15));
    return min(x,b);
}
float _33(vec2 uv) {
    uv.y-=.1;
    uv.y = abs(uv.y);
    uv.y-=.25;
    if(atan(uv.x,uv.y)>-1.)return abs(length(uv)-.25);
    else return min(length(uv+vec2(.211,-.134)),length(uv+vec2(.0,.25)));
}
float _44(vec2 uv) {
    float x = min(length(vec2(uv.x-.15,max(0.,abs(uv.y-.1)-.5))),
                  line(uv,vec2(0.15,0.6),vec2(-.25,-.1)));
    return min(x,length(vec2(max(0.,abs(uv.x)-.25),uv.y+.1)));
}
float _55(vec2 uv) {
    float b = min(length(vec2(max(0.,abs(uv.x)-.25),uv.y-.6)),
                  length(vec2(uv.x+.25,max(0.,abs(uv.y-.36)-.236))));
    uv.y += 0.1;
    uv.x += 0.05;
    float c = abs(length(vec2(uv.x,max(0.,abs(uv.y)-.0)))-.3);
    float bb=0.;
    if(abs(atan(uv.x,uv.y)+1.57)<.86 && uv.x<0.)bb=length(uv+vec2(.2,.224));
    else bb=c;
    return min(b,bb);
}
float _66(vec2 uv) {
    uv.y-=.075;
    uv = -uv;
    float b = abs(length(vec2(uv.x,max(0.,abs(uv.y)-.275)))-.25);
    uv.y-=.175;
    float c = abs(length(vec2(uv.x,max(0.,abs(uv.y)-.05)))-.25);
    float bb=0.;
    if(cos(atan(uv.x,uv.y+.45)+0.65)<0.||(uv.x>0.&& uv.y<0.)) bb=b;
    else bb=length(uv+vec2(0.2,0.6));
    return min(c,bb);
}
float _77(vec2 uv) {
    return min(length(vec2(max(0.,abs(uv.x)-.25),uv.y-.6)),
               line(uv,vec2(-0.25,-0.39),vec2(0.25,0.6)));
}
float _88(vec2 uv) {
    float l = length(vec2(max(0.,abs(uv.x)-.08),uv.y-.1+uv.x*.07));
    uv.y-=.1;
    uv.y = abs(uv.y);
    uv.y-=.245;
    return min(abs(length(uv)-.255),l);
}
float _99(vec2 uv) {
    uv.y-=.125;
    float b = abs(length(vec2(uv.x,max(0.,abs(uv.y)-.275)))-.25);
    uv.y-=.175;
    float c = abs(length(vec2(uv.x,max(0.,abs(uv.y)-.05)))-.25);
    float bb=0.;
    if(cos(atan(uv.x,uv.y+.45)+0.65)<0.||(uv.x>0.&& uv.y<0.))bb=b;
    else bb=length(uv+vec2(0.2,0.6));
    return min(c,bb);
}
float _00(vec2 uv) {
    uv.y-=.1;
    return abs(length(vec2(uv.x,max(0.,abs(uv.y)-.25)))-.25);
}

//Symbols
float ddot(vec2 uv) {
    uv.y+=.4;
    return length(uv)*0.97;//-.03;
}
float comma(vec2 uv) {
    return min(ddot(uv),line(uv,vec2(.031,-.405),vec2(-.029,-.52)));
}
float exclam(vec2 uv) {
    return min(ddot(uv),length(vec2(uv.x,max(0.,abs(uv.y-.2)-.4)))-uv.y*.06);
}
float question(vec2 uv) {
    float x = min(ddot(uv),length(vec2(uv.x,max(0.,abs(uv.y+.035)-.1125))));
    uv.y-=.35;
    uv.x += 0.025;
    float b=0.;
    if(abs(atan(uv.x,uv.y)-1.05)<2.)b=abs(length(uv)-.275);
    else b=length(uv+vec2(.225,-.16))-.0;
    return min(x,b);
}
float open1(vec2 uv) {
    uv.x-=.62;
    if(abs(atan(uv.x,uv.y)+1.57)<1.)return abs(length(uv)-.8);
    else return length(vec2(uv.x+.435,abs(uv.y)-.672));
}
float close1(vec2 uv) {
    uv.x = -uv.x;
    return open1(uv);
}
float dotdot(vec2 uv) {
    uv.y -= .1;
    uv.y = abs(uv.y);
    uv.y-=.25;
    return length(uv);
}
float dotcomma(vec2 uv) {
    uv.y -= .1;
    float x = line(uv,vec2(.0,-.28),vec2(-.029,-.32));
    uv.y = abs(uv.y);
    uv.y-=.25;
    return min(length(uv),x);
}
float eequal(vec2 uv) {
    uv.y -= .1;
    uv.y = abs(uv.y);
    return length(vec2(max(0.,abs(uv.x)-.25),uv.y-.15));
}
float aadd(vec2 uv) {
    uv.y -= .1;
    return min(length(vec2(max(0.,abs(uv.x)-.25),uv.y)),
               length(vec2(uv.x,max(0.,abs(uv.y)-.25))));
}
float ssub(vec2 uv) {
    return length(vec2(max(0.,abs(uv.x)-.25),uv.y-.1));
}
float mmul(vec2 uv) {
    uv.y -= .1;
    uv = abs(uv);
    return min(line(uv,vec2(0.866*.25,0.5*.25),vec2(0.))
              ,length(vec2(uv.x,max(0.,abs(uv.y)-.25))));
}
float ddiv(vec2 uv) {
    return line(uv,vec2(-0.25,-0.4),vec2(0.25,0.6));
}
float lt(vec2 uv) {
    uv.y-=.1;
    uv.y = abs(uv.y);
    return line(uv,vec2(0.25,0.25),vec2(-0.25,0.));
}
float gt(vec2 uv) {
    uv.x=-uv.x;
    return lt(uv);
}
float hash(vec2 uv) {
    uv.y-=.1;
    uv.x -= uv.y*.1;
    uv = abs(uv);
    return min(length(vec2(uv.x-.125,max(0.,abs(uv.y)-.3))),
               length(vec2(max(0.,abs(uv.x)-.25),uv.y-.125)));
}
float and(vec2 uv) {
    uv.y-=.44;
    uv.x+=.05;
    float x = 0.;
    if(abs(atan(uv.x,uv.y))<2.356)x=abs(length(uv)-.15);
    else x=1.0;
    x = min(x,line(uv,vec2(-0.106,-0.106),vec2(0.4,-0.712)));
    x = min(x,line(uv,vec2( 0.106,-0.106),vec2(-0.116,-0.397)));
    uv.x-=.025;
    uv.y+=.54;
    float b=0.;
    if(abs(atan(uv.x,uv.y)-.785)>1.57)b=abs(length(uv)-.2);
    else b=1.0;
    x = min(x,b);
    return min(x,line(uv,vec2( 0.141,-0.141),vec2( 0.377,0.177)));
}
float or(vec2 uv) {
    uv.y -= .1;
    return length(vec2(uv.x,max(0.,abs(uv.y)-.5)));
}
float und(vec2 uv) {
    return length(vec2(max(0.,abs(uv.x)-.25),uv.y+.4));
}
float open2(vec2 uv) {
    uv.y -= .1;
    uv.y = abs(uv.y);
    return min(length(vec2(uv.x+.125,max(0.,abs(uv.y)-.5))),
               length(vec2(max(0.,abs(uv.x)-.125),uv.y-.5)));
}
float close2(vec2 uv) {
    uv.x=-uv.x;
    return open2(uv);
}
float open3(vec2 uv) {
    uv.y -= .1;
    uv.y = abs(uv.y);
    float x = length(vec2(
                abs(length(vec2((uv.x*sign(uv.y-.25)-.2),
                            max(0.0,abs(uv.y-.25)-.05) ))-0.2)
               ,max(0.,abs(uv.x)-.2)));
    return  x;
    
}
float close3(vec2 uv) {
    uv.x=-uv.x;
    return open3(uv);
}

vec2 clc(vec2 uv, float cp, float w, float ital) {
    return uv-vec2(cp-(w*.5)+uv.y*ital,0.);
}

void ch(in int l,in vec2 uv,in float ital,inout float cp, inout float x){
    if (l==97) {
        cp+=0.7; x=min(x,aa(clc(uv,cp,0.7,ital)));
    }
    else if (l==98) {
        cp+=0.7; x=min(x,bb(clc(uv,cp,0.7,ital)));
    }
    else if (l==99) {
        cp+=0.7; x=min(x,cc(clc(uv,cp,0.7,ital)));
    }
    else if (l==100) {
        cp+=0.7; x=min(x,dd(clc(uv,cp,0.7,ital)));
    }
    else if (l==101) {
        cp+=0.7; x=min(x,ee(clc(uv,cp,0.7,ital)));
    }
    else if (l==102) {
        cp+=0.6; x=min(x,ff(clc(uv,cp,0.6,ital)));
    }
    else if (l==103) {
        cp+=0.7; x=min(x,gg(clc(uv,cp,0.7,ital)));
    }
    else if (l==104) {
        cp+=0.7; x=min(x,hh(clc(uv,cp,0.7,ital)));
    }
    else if (l==105) {
        cp+=0.3; x=min(x,ii(clc(uv,cp,0.3,ital)));
    }
    else if (l==106) {
        cp+=0.3; x=min(x,jj(clc(uv,cp,0.3,ital)));
    }
    else if (l==107) {
        cp+=0.7; x=min(x,kk(clc(uv,cp,0.7,ital)));
    }
    else if (l==108) {
        cp+=0.3; x=min(x,ll(clc(uv,cp,0.3,ital)));
    }
    else if (l==109) {
        cp+=0.9; x=min(x,mm(clc(uv,cp,0.9,ital)));
    }
    else if (l==110) {
        cp+=0.7; x=min(x,nn(clc(uv,cp,0.7,ital)));
    }
    else if (l==111) {
        cp+=0.7; x=min(x,oo(clc(uv,cp,0.7,ital)));
    }
    else if (l==112) {
        cp+=0.7; x=min(x,pp(clc(uv,cp,0.7,ital)));
    }
    else if (l==113) {
        cp+=0.7; x=min(x,qq(clc(uv,cp,0.7,ital)));
    }
    else if (l==114) {
        cp+=0.7; x=min(x,rr(clc(uv,cp,0.7,ital)));
    }
    else if (l==115) {
        cp+=0.7; x=min(x,ss(clc(uv,cp,0.7,ital)));
    }
    else if (l==116) {
        cp+=0.7; x=min(x,tt(clc(uv,cp,0.7,ital)));
    }
    else if (l==117) {
        cp+=0.7; x=min(x,uu(clc(uv,cp,0.7,ital)));
    }
    else if (l==118) {
        cp+=0.7; x=min(x,vv(clc(uv,cp,0.7,ital)));
    }
    else if (l==119) {
        cp+=0.9; x=min(x,ww(clc(uv,cp,0.9,ital)));
    }
    else if (l==120) {
        cp+=0.8; x=min(x,xx(clc(uv,cp,0.8,ital)));
    }
    else if (l==121) {
        cp+=0.8; x=min(x,yy(clc(uv,cp,0.8,ital)));
    }
    else if (l==122) {
        cp+=0.7; x=min(x,zz(clc(uv,cp,0.7,ital)));
    }
    else if (l==65) {
        cp+=0.7; x=min(x,AA(clc(uv,cp,0.7,ital)));
    }
    else if (l==66) {
        cp+=0.7; x=min(x,BB(clc(uv,cp,0.7,ital)));
    }
    else if (l==67) {
        cp+=0.7; x=min(x,CC(clc(uv,cp,0.7,ital)));
    }
    else if (l==68) {
        cp+=0.7; x=min(x,DD(clc(uv,cp,0.7,ital)));
    }
    else if (l==69) {
        cp+=0.7; x=min(x,EE(clc(uv,cp,0.7,ital)));
    }
    else if (l==70) {
        cp+=0.7; x=min(x,FF(clc(uv,cp,0.7,ital)));
    }
    else if (l==71) {
        cp+=0.6; x=min(x,GG(clc(uv,cp,0.6,ital)));
    }
    else if (l==72) {
        cp+=0.7; x=min(x,HH(clc(uv,cp,0.7,ital)));
    }
    else if (l==73) {
        cp+=0.5; x=min(x,II(clc(uv,cp,0.5,ital)));
    }
    else if (l==74) {
        cp+=0.5; x=min(x,JJ(clc(uv,cp,0.5,ital)));
    }
    else if (l==75) {
        cp+=0.7; x=min(x,KK(clc(uv,cp,0.7,ital)));
    }
    else if (l==76) {
        cp+=0.5; x=min(x,LL(clc(uv,cp,0.5,ital)));
    }
    else if (l==77) {
        cp+=0.9; x=min(x,MM(clc(uv,cp,0.9,ital)));
    }
    else if (l==78) {
        cp+=0.7; x=min(x,NN(clc(uv,cp,0.7,ital)));
    }
    else if (l==79) {
        cp+=0.7; x=min(x,OO(clc(uv,cp,0.7,ital)));
    }
    else if (l==80) {
        cp+=0.7; x=min(x,PP(clc(uv,cp,0.7,ital)));
    }
    else if (l==81) {
        cp+=0.7; x=min(x,QQ(clc(uv,cp,0.7,ital)));
    }
    else if (l==82) {
        cp+=0.7; x=min(x,RR(clc(uv,cp,0.7,ital)));
    }
    else if (l==83) {
        cp+=0.7; x=min(x,SS(clc(uv,cp,0.7,ital)));
    }
    else if (l==84) {
        cp+=0.7; x=min(x,TT(clc(uv,cp,0.7,ital)));
    }
    else if (l==85) {
        cp+=0.7; x=min(x,UU(clc(uv,cp,0.7,ital)));
    }
    else if (l==86) {
        cp+=0.7; x=min(x,VV(clc(uv,cp,0.7,ital)));
    }
    else if (l==87) {
        cp+=0.9; x=min(x,WW(clc(uv,cp,0.9,ital)));
    }
    else if (l==88) {
        cp+=0.8; x=min(x,XX(clc(uv,cp,0.8,ital)));
    }
    else if (l==89) {
        cp+=0.8; x=min(x,YY(clc(uv,cp,0.8,ital)));
    }
    else if (l==90) {
        cp+=0.7; x=min(x,ZZ(clc(uv,cp,0.7,ital)));
    }
    else if (l==48) {
        cp+=0.7; x=min(x,_00(clc(uv,cp,0.7,ital)));
    }
    else if (l==49) {
        cp+=0.7; x=min(x,_11(clc(uv,cp,0.7,ital)));
    }
    else if (l==50) {
        cp+=0.7; x=min(x,_22(clc(uv,cp,0.7,ital)));
    }
    else if (l==51) {
        cp+=0.7; x=min(x,_33(clc(uv,cp,0.7,ital)));
    }
    else if (l==52) {
        cp+=0.7; x=min(x,_44(clc(uv,cp,0.7,ital)));
    }
    else if (l==53) {
        cp+=0.7; x=min(x,_55(clc(uv,cp,0.7,ital)));
    }
    else if (l==54) {
        cp+=0.7; x=min(x,_66(clc(uv,cp,0.7,ital)));
    }
    else if (l==55) {
        cp+=0.7; x=min(x,_77(clc(uv,cp,0.7,ital)));
    }
    else if (l==56) {
        cp+=0.7; x=min(x,_88(clc(uv,cp,0.7,ital)));
    }
    else if (l==57) {
        cp+=0.7; x=min(x,_99(clc(uv,cp,0.7,ital)));
    }
    else if (l==32) {
    cp+=.5;
    }
    else if (l==46) {
        cp+=0.3; x=min(x,ddot(clc(uv,cp,0.3,ital)));
    }
    else if (l==44) {
        cp+=0.3; x=min(x,comma(clc(uv,cp,0.3,ital)));
    }
    else if (l==33) {
        cp+=0.3; x=min(x,exclam(clc(uv,cp,0.3,ital)));
    }
    else if (l==63) {
        cp+=0.8; x=min(x,question(clc(uv,cp,0.8,ital)));
    }
    else if (l==40) {
        cp+=0.7; x=min(x,open1(clc(uv,cp,0.7,ital)));
    }
    else if (l==41) {
        cp+=0.7; x=min(x,close1(clc(uv,cp,0.7,ital)));
    }
    else if (l==58) {
        cp+=0.3; x=min(x,dotdot(clc(uv,cp,0.3,ital)));
    }
    else if (l==59) {
        cp+=0.3; x=min(x,dotcomma(clc(uv,cp,0.3,ital)));
    }
    else if (l==61) {
        cp+=0.7; x=min(x,eequal(clc(uv,cp,0.7,ital)));
    }
    else if (l==43) {
        cp+=0.7; x=min(x,aadd(clc(uv,cp,0.7,ital)));
    }
    else if (l==45) {
        cp+=0.7; x=min(x,ssub(clc(uv,cp,0.7,ital)));
    }
    else if (l==42) {
        cp+=0.7; x=min(x,mmul(clc(uv,cp,0.7,ital)));
    }
    else if (l==47) {
        cp+=0.7; x=min(x,ddiv(clc(uv,cp,0.7,ital)));
    }
    else if (l==60) {
        cp+=0.7; x=min(x,lt(clc(uv,cp,0.7,ital)));
    }
    else if (l==62) {
        cp+=0.7; x=min(x,gt(clc(uv,cp,0.7,ital)));
    }
    else if (l==35) {
        cp+=0.7; x=min(x,hash(clc(uv,cp,0.7,ital)));
    }
    else if (l==38) {
        cp+=0.9; x=min(x,and(clc(uv,cp,0.9,ital)));
    }
    else if (l==124) {
        cp+=0.3; x=min(x,or(clc(uv,cp,0.3,ital)));
    }
    else if (l==95) {
        cp+=0.7; x=min(x,und(clc(uv,cp,0.7,ital)));
    }
    else if (l==91) {
        cp+=0.6; x=min(x,open2(clc(uv,cp,0.6,ital)));
    }
    else if (l==93) {
        cp+=0.6; x=min(x,close2(clc(uv,cp,0.6,ital)));
    }
    else if (l==123) {
        cp+=0.7; x=min(x,open3(clc(uv,cp,0.7,ital)));
    }
    else if (l==125) {
        cp+=0.7; x=min(x,close3(clc(uv,cp,0.7,ital)));
    }
    else{
    cp+=.5;
    }
}

void get_text_text(int id, out ivec4 t1, out ivec4 t2, out ivec2 t3){
	int a=int(texelFetch(text_array,ivec2(7,id),0).r);
	int b=int(texelFetch(text_array,ivec2(8,id),0).r);
	int c=int(texelFetch(text_array,ivec2(9,id),0).r);
	int d=int(texelFetch(text_array,ivec2(10,id),0).r);
	int e=int(texelFetch(text_array,ivec2(11,id),0).r);
	int f=int(texelFetch(text_array,ivec2(12,id),0).r);
	int g=int(texelFetch(text_array,ivec2(13,id),0).r);
	int h=int(texelFetch(text_array,ivec2(14,id),0).r);
	int i=int(texelFetch(text_array,ivec2(15,id),0).r);
	int j=int(texelFetch(text_array,ivec2(16,id),0).r);
	t1=ivec4(a,b,c,d);
	t2=ivec4(e,f,g,h);
	t3=ivec2(i,j);
}

void ITAL(inout float ital){ital= 0.15-ital;}

float mi( vec2 U, float scale, int id)
{
    U+=-0.5;
    U.x+=.02;
	vec2 uv = U* scale;

    float x = 100.;
    float cp = 0.;
    float ital = 0.0;
	
	ivec4 t1;
	ivec4 t2;
	ivec2 t3;
	get_text_text(id,t1,t2,t3);

    ch(t1.x,uv,ital,cp,x);
    ch(t1.y,uv,ital,cp,x);
    ch(t1.z,uv,ital,cp,x);
	ch(t1.w,uv,ital,cp,x);
    ch(t2.x,uv,ital,cp,x);
    ch(t2.y,uv,ital,cp,x);
    ch(t2.z,uv,ital,cp,x);
	ch(t2.w,uv,ital,cp,x);
    ch(t3.x,uv,ital,cp,x);
    ch(t3.y,uv,ital,cp,x);


    return x;
}


float print_text(vec2 U, float scale, int id){
	return mi(U,scale,id);
}

float circleSDF(vec2 p, float size) {
	return length(p) - size;
}

float boxSDF(vec2 p, vec2 size) {
	vec2 r = abs(p) - size;
    return min(max(r.x, r.y),0.) + length(max(r,vec2(0,0)));
}

float sdEquilateralTriangle( in vec2 p )
{
    float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    return -length(p)*sign(p.y);
}

vec3 colormap(float x) {
    float s = sin(x*6.28);
    if (x > 0.) {
    	return vec3(1,1,1.+s)/2.;
    } else {
        return vec3(1,1.+s,1)/2.;
    }
}

void AddObj(inout float dist, inout vec3 color, float d, vec3 c) {
    if (dist > d) {
        dist = d;
        color = c;
    }
}

// [0] [0]=size or array
// [1] [0-1]=position, [2] box size, [3-5]color [6]rot [7]glow
vec3 get_box_val(int id){
	float a=texelFetch(box_array,ivec2(0,id),0).r;
	float b=texelFetch(box_array,ivec2(1,id),0).r;
	float c=texelFetch(box_array,ivec2(2,id),0).r;
	return vec3(a,b,c);
}

vec4 get_box_col(int id){
	float a=texelFetch(box_array,ivec2(3,id),0).r;
	float b=texelFetch(box_array,ivec2(4,id),0).r;
	float c=texelFetch(box_array,ivec2(5,id),0).r;
	float d=texelFetch(box_array,ivec2(6,id),0).r;
	return vec4(a,b,c,d);
}

vec3 get_circle_val(int id){
	float a=texelFetch(circle_array,ivec2(0,id),0).r;
	float b=texelFetch(circle_array,ivec2(1,id),0).r;
	float c=texelFetch(circle_array,ivec2(2,id),0).r;
	return vec3(a,b,c);
}

vec3 get_circle_col(int id){
	float a=texelFetch(circle_array,ivec2(3,id),0).r;
	float b=texelFetch(circle_array,ivec2(4,id),0).r;
	float c=texelFetch(circle_array,ivec2(5,id),0).r;
	return vec3(a,b,c);
}

vec3 get_tri_val(int id){
	float a=texelFetch(tri_array,ivec2(0,id),0).r;
	float b=texelFetch(tri_array,ivec2(1,id),0).r;
	float c=texelFetch(tri_array,ivec2(2,id),0).r;
	return vec3(a,b,c);
}

vec4 get_tri_col(int id){
	float a=texelFetch(tri_array,ivec2(3,id),0).r;
	float b=texelFetch(tri_array,ivec2(4,id),0).r;
	float c=texelFetch(tri_array,ivec2(5,id),0).r;
	float d=texelFetch(tri_array,ivec2(6,id),0).r;
	return vec4(a,b,c,d);
}

vec3 get_line_val(int id){
	float a=texelFetch(line_array,ivec2(0,id),0).r;
	float b=texelFetch(line_array,ivec2(1,id),0).r;
	float c=texelFetch(line_array,ivec2(2,id),0).r;
	return vec3(a,b,c);
}

vec4 get_line_col(int id){
	float a=texelFetch(line_array,ivec2(3,id),0).r;
	float b=texelFetch(line_array,ivec2(4,id),0).r;
	float c=texelFetch(line_array,ivec2(5,id),0).r;
	float d=texelFetch(line_array,ivec2(6,id),0).r;
	return vec4(a,b,c,d);
}

vec3 get_text_val(int id){
	float a=texelFetch(text_array,ivec2(0,id),0).r;
	float b=texelFetch(text_array,ivec2(1,id),0).r;
	float c=texelFetch(text_array,ivec2(2,id),0).r;
	return vec3(a,b,c);
}

vec4 get_text_col(int id){
	float a=texelFetch(text_array,ivec2(3,id),0).r;
	float b=texelFetch(text_array,ivec2(4,id),0).r;
	float c=texelFetch(text_array,ivec2(5,id),0).r;
	float d=texelFetch(text_array,ivec2(6,id),0).r;
	return vec4(a,b,c,d);
}

bool get_box_glow(int id){
	if(int(texelFetch(box_array,ivec2(7,id),0).r)==1)return true;
	else return false;
}

bool get_tri_glow(int id){
	if(int(texelFetch(tri_array,ivec2(7,id),0).r)==1)return true;
	else return false;
}

bool get_line_glow(int id){
	if(int(texelFetch(line_array,ivec2(7,id),0).r)==1)return true;
	else return false;
}

bool get_circle_glow(int id){
	if(int(texelFetch(circle_array,ivec2(7,id),0).r)==1)return true;
	else return false;
}

bool get_text_glow(int id){
	if(int(texelFetch(text_array,ivec2(17,id),0).r)==1)return true;
	else return false;
}

mat2 MD(float a){return mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));}

void scene(in vec2 p, out vec3 color, out float dist) {
    color = vec3(0,0,0);
    dist = 1e9;
	int size_box=int(get_box_val(0).r);
	int size_circle=int(get_circle_val(0).r);
	int size_line=int(get_line_val(0).r);
	int size_text=int(get_text_val(0).r);
	int size_tri=int(get_tri_val(0).r);
	int max_elems=5;
	
	for(int i=0;i<min(max_elems,size_tri);i++){
	vec3 tval=get_tri_val(i+1);
	vec4 tcol=get_tri_col(i+1);
	if(get_tri_glow(i+1))tcol.rgb*=2.;
	AddObj(dist, color, 0.5*sdEquilateralTriangle((p - vec2(tval.rg)*10.)*MD(tcol.a)), tcol.rgb);
	}
	
	for(int i=0;i<min(max_elems,size_box);i++){
	vec3 tval=get_box_val(i+1);
	vec4 tcol=get_box_col(i+1);
	if(get_box_glow(i+1))tcol.rgb*=2.;
	AddObj(dist, color, 0.5*boxSDF((p - vec2(tval.rg)*10.)*MD(tcol.a), vec2(tval.b)*10.), tcol.rgb);
	}
	
	for(int i=0;i<min(max_elems,size_circle);i++){
	vec3 tval=get_circle_val(i+1);
	vec3 tcol=get_circle_col(i+1);
	if(get_circle_glow(i+1))tcol.rgb*=2.;
	AddObj(dist, color, 0.5*circleSDF(p - vec2(tval.rg)*10., (tval.b)*10.), tcol);
	}
	
	for(int i=0;i<min(max_elems,size_line);i++){
	vec3 tval=get_line_val(i+1);
	vec4 tcol=get_line_col(i+1);
	if(get_line_glow(i+1))tcol.rgb*=2.;
	AddObj(dist, color, 0.5*boxSDF((p - vec2(tval.rg)*10.)*MD(tcol.a), vec2(0.005,tval.b)*10.), tcol.rgb);
	}
	
	for(int i=0;i<min(max_elems,size_text);i++){
	vec3 tval=get_text_val(i+1);
	vec4 tcol=get_text_col(i+1);
	if(get_text_glow(i+1))tcol.rgb*=2.;
	float d0= print_text((p - vec2(tval.rg)*10.+0.*vec2(0.05,0.07)*10.)*MD(tcol.a)+vec2(0.05,0.05)*10.+0.*vec2(-0.2,0.)*10.,3.*(1./(tval.b+1.)),i+1);
	float d1=smoothstep(-1.5,1.6,d0)-0.50;
	AddObj(dist, color, d1, tcol.rgb);
	}
}

void trace(vec2 p, vec2 dir, out vec3 c) {
	c = vec3(0,0,0);
    for (int i=0;i<256;i++) {
        float d;
        scene(p, c, d);
        if (d < 1e-3) return;
        if (d > 1e1) break;
        p += dir * d;
    }
    c = vec3(0,0,0);
}

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
        vec2(12.9898,78.233)))*
        43758.5453123);
}

vec3 sdf_glow(vec3 col,float d){
    return col/(100.*max(d,0.0001));
}

vec4 add_text_col_glow(vec2 p){
	int size_text=int(get_text_val(0).r);
	int max_elems=5;
	float a=0.;
	float dist=1e9;
	vec3 col=vec3(.0);
	for(int i=0;i<min(max_elems,size_text);i++){
	vec3 tval=get_text_val(i+1);
	vec4 tcol=get_text_col(i+1);
	float d0=print_text((p - vec2(tval.rg)*10.+0.*vec2(0.05,0.07)*10.)*MD(tcol.a)+vec2(0.05,0.05)*10.+0.*vec2(-0.2,0.)*10.,3.*(1./(tval.b+1.)),i+1);
    float d1=smoothstep(-01.5,01.6,d0)-0.50;
	if(get_text_glow(i+1)){
	dist=min(d1,dist);
    col+=sdf_glow(tcol.rgb,d1);}
	else{
	float at=smoothstep(0.01,0.,d1);
    col+=tcol.rgb*at;
	a=max(at,a);
	}
	}
    return vec4(col,max(clamp(dist,0.,1.),clamp(a,0.,1.)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, vec2 iResolution )
{
	vec2 ouv = fragCoord.xy / iResolution.xy;
    int SAMPLES=256;
    highp vec2 uv = ((fragCoord-(iResolution.xy/2.f))/iResolution.y)*10.;
    highp vec3 col = vec3(0,0,0);
    for (int i = 0; i < SAMPLES; i++) {
        float t = ((float(i) + random(uv+float(i)+iTime)) / float(SAMPLES));
		t=t * 2. * 3.1415;
        vec3 c;
        trace(uv, vec2(cos(t), sin(t)), c);
        col += c;
    }
    col /= float(SAMPLES);
	//vec4 tc=clamp(add_text_col(uv),vec4(0.),vec4(1.));
    vec4 tc=clamp(add_text_col_glow(uv),vec4(0.),vec4(1.));
    col=tc.rgb+col;
	ouv.y=1.-ouv.y;
	col+=texture(iChannel1,ouv).rgb;
    fragColor = vec4(col,1.0);
}


void fragment(){
	vec2 iResolution=floor(1./TEXTURE_PIXEL_SIZE);
	vec2 fragCoord=UV*iResolution;
	ivec2 tre=ivec2(vec2(float(iFrame1%14),float(iFrame1/14))/vec2(14.,8.)*vec2(iResolution));
	ivec2 trst=ivec2(vec2(1./14.,1./8.)*iResolution);
	if(all(greaterThanEqual(ivec2(fragCoord),tre))&&all(lessThanEqual(ivec2(fragCoord),tre+trst))){
		mainImage(COLOR,fragCoord,iResolution);
	}
	else {
		discard;return;
	}
}