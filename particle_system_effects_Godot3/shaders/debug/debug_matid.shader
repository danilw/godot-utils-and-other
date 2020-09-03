shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D iChannel0;

const float dv=0.25;
int decode_mid(float mid){
	if(mid<dv){
		return -1;
	}
	return int(mid/dv)-1;
}

float DigitBin(in int x)
{
    if (x==0)return 480599.0;
	else if(x==1) return 139810.0;
	else if(x==2) return 476951.0;
	else if(x==3) return 476999.0;
	else if(x==4) return 350020.0;
	else if(x==5) return 464711.0;
	else if(x==6) return 464727.0;
	else if(x==7) return 476228.0;
	else if(x==8) return 481111.0;
	else if(x==9) return 481095.0;
	return 0.0;
}

float PrintValue(vec2 fragCoord, vec2 pixelCoord, vec2 fontSize, float value,
		float digits, float decimals) {
	vec2 charCoord = (fragCoord - pixelCoord) / fontSize;
	if(charCoord.y < 0.0 || charCoord.y >= 1.0) return 0.0;
	float bits = 0.0;
	float digitIndex1 = digits - floor(charCoord.x)+ 1.0;
	if(- digitIndex1 <= decimals) {
		float pow1 = pow(10.0, digitIndex1);
		float absValue = abs(value);
		float pivot = max(absValue, 1.5) * 10.0;
		if(pivot < pow1) {
			if(value < 0.0 && pivot >= pow1 * 0.1) bits = 1792.0;
		} else if(digitIndex1 == 0.0) {
			if(decimals > 0.0) bits = 2.0;
		} else {
			value = digitIndex1 < 0.0 ? fract(absValue) : absValue * 10.0;
			bits = DigitBin(int (mod(value / pow1, 10.0)));
		}
	}
	return floor(mod(bits / pow(2.0, floor(fract(charCoord.x) * 4.0) + floor(charCoord.y * 5.0) * 4.0), 2.0));
}

float print_n(in vec2 uv ,float nm){
	uv.x+=0.5;
   	vec2 vPixelCoord2 = vec2(0.);
	float fValue2 = nm;
	float fDigits = 2.0;
	float fDecimalPlaces = 0.0;
    vec2 fontSize = vec2(8.)/vec2(16.,9.);
	float fIsDigit2 = PrintValue(uv, vPixelCoord2, fontSize, fValue2, fDigits, fDecimalPlaces);
    return fIsDigit2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    vec2 uv = fragCoord/iResolution.xy;
	vec4 data=texelFetch(iChannel0,ivec2(fragCoord),0);
	int mid=decode_mid(data.r*data.a);
	vec3 c=vec3(0.);
	if(mid<0){
		c=vec3(0.5);
	}else{
		switch(mid%5){
			case 0:c=vec3(0.8,0.05,0.05);break;
			case 1:c=vec3(0.05,0.8,0.05);break;
			case 2:c=vec3(0.05,0.05,0.8);break;
			case 3:c=vec3(0.8,0.8,0.05);break;
			case 4:c=vec3(0.05,0.8,0.8);break;
		}
	}
	vec2 guv=fract(uv*20.);
	float d=print_n(guv,float(mid));
    fragColor=vec4(c*d,d*(0.85));
}

void fragment(){
    vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
    mainImage(COLOR,FRAGCOORD.xy,iResolution);
	COLOR=vec4(vec3(texture(iChannel0,UV).r*texture(iChannel0,UV).a),1.);
}
