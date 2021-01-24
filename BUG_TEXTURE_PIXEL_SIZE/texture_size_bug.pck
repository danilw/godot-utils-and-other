GDPC                                                                               <   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stexp(      U      -��`�0��x�5�[   res://2d.shader �      /	      ^0����d�P�/G(��   res://3d.shader        �      �M�4a�a�8h��p   res://Node2D.tscn         �      Lh��:��*���pD�   res://Spatial.tscn  �            2�C~W �� �ˍ�G�   res://Viewport.gd.remap P8      #       ?J��l��ڛ�����O   res://Viewport.gdc  �"      �      m������ƙ��^�W   res://default_env.tres  �'      �       um�`�N��<*ỳ�8   res://icon.png  �8      �      G1?��z�c��vN��   res://icon.png.import   �5      �      �����%��(#AB�   res://project.binarypE      �      �Z`]�2�U d6�Z��N        shader_type canvas_item;
render_mode blend_premul_alpha,unshaded;


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

vec3 print_n(in vec2 uv ,float nm){
    	vec2 vPixelCoord2 = vec2(0.);
		float fValue2 = nm;
		float fDigits = 1.0;
		float fDecimalPlaces = 0.0;
        vec2 fontSize = vec2(30.)/vec2(1280,720);
		float fIsDigit2 = PrintValue(uv, vPixelCoord2, fontSize, fValue2, fDigits, fDecimalPlaces);
        return vec3(1.0, 1.0, 1.0)* fIsDigit2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, vec2 iResolution, vec2 iResolution2 )
{
    vec2 uv = fragCoord/iResolution.xy;
    uv.y=1.-uv.y;
    fragColor=vec4(print_n(uv+vec2(-0.35,-0.5),iResolution.x)*vec3(1.,1.,0.1),1.);
    fragColor+=vec4(print_n(uv+vec2(-0.35,-0.25),iResolution.y)*vec3(1.,1.,0.1),1.);
    fragColor+=vec4(print_n(uv+vec2(-0.65,-0.5),iResolution2.x)*vec3(0.1,1.,1.0),1.);
    fragColor+=vec4(print_n(uv+vec2(-0.65,-0.25),iResolution2.y)*vec3(0.1,1.,1.0),1.);
}

void fragment(){
    vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
    mainImage(COLOR,FRAGCOORD.xy,iResolution, vec2(textureSize(TEXTURE,0).xy));
    COLOR.a=1.;
    vec2 tuv=UV*2.5;
    if((tuv.x<1.)&&(tuv.y<1.))COLOR.rgb+=texture(TEXTURE,UV*3.).rgb;
}
 shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;

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

vec3 print_n(in vec2 uv ,float nm){
    	vec2 vPixelCoord2 = vec2(0.);
		float fValue2 = nm;
		float fDigits = 1.0;
		float fDecimalPlaces = 0.0;
        vec2 fontSize = vec2(30.)/vec2(1280,720);
		float fIsDigit2 = PrintValue(uv, vPixelCoord2, fontSize, fValue2, fDigits, fDecimalPlaces);
        return vec3(1.0, 1.0, 1.0)* fIsDigit2;
}

void mainImage( out vec4 fragColor, in vec2 uv, vec2 iResolution )
{
    uv.y=1.-uv.y;
    float scale=0.24;
    uv*=scale;
    fragColor=vec4(print_n(uv+vec2(-0.5,-0.5)*scale,iResolution.x),1.);
    fragColor+=vec4(print_n(uv+vec2(-0.5,-0.25)*scale,iResolution.y),1.);
}

void fragment() {
  vec4 col;
  mainImage(col,UV,VIEWPORT_SIZE.xy);
  ALBEDO =  col.rgb;
}
             [gd_scene load_steps=8 format=2]

[ext_resource path="res://Spatial.tscn" type="PackedScene" id=1]
[ext_resource path="res://2d.shader" type="Shader" id=2]
[ext_resource path="res://Viewport.gd" type="Script" id=3]

[sub_resource type="ShaderMaterial" id=1]
shader = ExtResource( 2 )

[sub_resource type="ViewportTexture" id=2]
viewport_path = NodePath("Viewport")

[sub_resource type="ViewportTexture" id=3]
viewport_path = NodePath("Viewport")

[sub_resource type="ViewportTexture" id=4]
viewport_path = NodePath("Viewport2")

[node name="Node2D" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Viewport" type="Viewport" parent="."]
size = Vector2( 1280, 720 )
hdr = false
render_target_v_flip = true
render_target_update_mode = 3
script = ExtResource( 3 )

[node name="Spatial" parent="Viewport" instance=ExtResource( 1 )]

[node name="Viewport2" type="Viewport" parent="."]
size = Vector2( 1280, 720 )
hdr = false
disable_3d = true
usage = 0
render_target_v_flip = true
render_target_update_mode = 3

[node name="Sprite" type="Sprite" parent="Viewport2"]
material = SubResource( 1 )
texture = SubResource( 2 )
centered = false

[node name="Control" type="Control" parent="."]
margin_right = 40.0
margin_bottom = 40.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="VBoxContainer" type="VBoxContainer" parent="Control"]
margin_right = 40.0
margin_bottom = 40.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="HBoxContainer" type="HBoxContainer" parent="Control/VBoxContainer"]
margin_right = 178.0
margin_bottom = 14.0

[node name="Label" type="Label" parent="Control/VBoxContainer/HBoxContainer"]
margin_right = 102.0
margin_bottom = 14.0
text = "Viewport 1 size:"

[node name="Label2" type="Label" parent="Control/VBoxContainer/HBoxContainer"]
margin_left = 106.0
margin_right = 178.0
margin_bottom = 14.0
text = "(1280, 720)"

[node name="HBoxContainer2" type="HBoxContainer" parent="Control/VBoxContainer"]
margin_top = 18.0
margin_right = 178.0
margin_bottom = 32.0

[node name="Label" type="Label" parent="Control/VBoxContainer/HBoxContainer2"]
margin_right = 102.0
margin_bottom = 14.0
text = "Viewport 2 size:"

[node name="Label2" type="Label" parent="Control/VBoxContainer/HBoxContainer2"]
margin_left = 106.0
margin_right = 178.0
margin_bottom = 14.0
text = "(1280, 720)"

[node name="Sprite" type="TextureRect" parent="."]
anchor_top = 0.5
anchor_bottom = 0.5
margin_left = 17.4614
margin_top = -131.414
margin_right = 1297.46
margin_bottom = 588.586
rect_scale = Vector2( 0.5, 0.5 )
texture = SubResource( 3 )
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Sprite2" type="TextureRect" parent="."]
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
margin_left = 34.0941
margin_top = -133.077
margin_right = 1314.09
margin_bottom = 586.923
rect_scale = Vector2( 0.5, 0.5 )
texture = SubResource( 4 )
__meta__ = {
"_edit_use_anchors_": false
}
       [gd_scene load_steps=5 format=2]

[ext_resource path="res://3d.shader" type="Shader" id=1]

[sub_resource type="CubeMesh" id=1]

[sub_resource type="ShaderMaterial" id=2]
shader = ExtResource( 1 )

[sub_resource type="QuadMesh" id=3]
size = Vector2( 2, 2 )

[node name="Spatial" type="Spatial"]

[node name="MeshInstance" type="MeshInstance" parent="."]
mesh = SubResource( 1 )
material/0 = null

[node name="Camera" type="Camera" parent="."]
transform = Transform( 1, 0, 0, 0, 0.869633, 0.493699, 0, -0.493699, 0.869633, 0, 2.46576, 3.65823 )

[node name="MeshInstance2" type="MeshInstance" parent="."]
transform = Transform( 1, 0, 0, 0, 0.901787, 0.43218, 0, -0.43218, 0.901787, 0, 1.95596, 1.91335 )
material_override = SubResource( 2 )
mesh = SubResource( 3 )
material/0 = null
  GDSC      
       �      �������¶���   �Ƅ�   �������Ӷ���   ������   ������   �����Ӈ�   �����ӄ�   ��������¶��   �������Ŷ���   ����׶��   ����������ض   �������Ӷ���   �������¶���   �����������¶���   ���Ӷ���   ζ��   ϶��   ���¶���   �����¶�   ���������Ӷ�      ../Viewport2   -   ../Control/VBoxContainer/HBoxContainer/Label2      .   ../Control/VBoxContainer/HBoxContainer2/Label2     	   ../Sprite      
   ../Sprite2           �        Sprite               ?                                           (      1   	   2   
   3      4      >      ?      F      W      X      |      �      �      �      �      �      �      �      �      �      �      �      �      �      �       3YY5;�  �  PQY5;�  �  P�  QY5;�  �  P�  QYY5;�  �  P�  QY5;�  �  P�  QYYYY;�  �  P�  R�  QYY0�  P�	  QV�  ;�
  �  PQT�  PQT�  PQT�  �  �  &PP�  P�  T�  Q�  P�
  T�  QQP�  P�  T�  Q�  P�
  T�  QQQV�  �  �  P�  P�
  T�  QR�  P�
  T�  QQ�  �  �  �  �  T�  �  �  �  �  T�  �>  P�  Q�  �  T�  �>  P�  T�  Q�  �  �  �  �  T�  P�  QT�  �  P�  R�  Q�  �  �  �  T�  �  P�	  R�	  Q�  �  T�  �  P�	  R�	  QY`              [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDST@   @           9  PNG �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx�ݜytTU��?��WK*�=���%�  F����0N��݂:���Q�v��{�[�����E�ӋH���:���B�� YHB*d_*�jyo�(*M�JR!h��S�T��w�߻���ro���� N�\���D�*]��c����z��D�R�[�
5Jg��9E�|JxF׵'�a���Q���BH�~���!����w�A�b
C1�dB�.-�#��ihn�����u��B��1YSB<%�������dA�����C�$+(�����]�BR���Qsu][`
�DV����у�1�G���j�G͕IY! L1�]��� +FS�IY!IP ��|�}��*A��H��R�tQq����D`TW���p\3���M���,�fQ����d��h�m7r�U��f������.��ik�>O�;��xm��'j�u�(o}�����Q�S�-��cBc��d��rI�Ϛ�$I|]�ơ�vJkZ�9>��f����@EuC�~�2�ym�ش��U�\�KAZ4��b�4������;�X婐����@Hg@���o��W�b�x�)����3]j_��V;K����7�u����;o�������;=|��Ŗ}5��0q�$�!?��9�|�5tv�C�sHPTX@t����w�nw��۝�8�=s�p��I}�DZ-̝�ǆ�'�;=����R�PR�ۥu���u��ǻC�sH`��>�p�P ���O3R�������۝�SZ7 �p��o�P!�
��� �l��ހmT�Ƴێ�gA��gm�j����iG���B� ܦ(��cX�}4ۻB��ao��"����� ����G�7���H���æ;,NW?��[��`�r~��w�kl�d4�������YT7�P��5lF�BEc��=<�����?�:]�������G�Μ�{������n�v��%���7�eoݪ��
�QX¬)�JKb����W�[�G ��P$��k�Y:;�����{���a��&�eפ�����O�5,;����yx�b>=fc�* �z��{�fr��7��p���Ôִ�P����t^�]͑�~zs.�3����4��<IG�w�e��e��ih�/ˆ�9�H��f�?����O��.O��;!��]���x�-$E�a1ɜ�u�+7Ȃ�w�md��5���C.��\��X��1?�Nغ/�� ��~��<:k?8��X���!���[���꩓��g��:��E����>��꩓�u��A���	iI4���^v:�^l/;MC��	iI��TM-$�X�;iLH���;iI1�Zm7����P~��G�&g�|BfqV#�M������%��TM��mB�/�)����f����~3m`��������m�Ȉ�Ƽq!cr�pc�8fd���Mۨkl�}P�Л�汻��3p�̤H�>+���1D��i�aۡz�
������Z�Lz|8��.ִQ��v@�1%&���͏�������m���KH�� �p8H�4�9����/*)�aa��g�r�w��F36���(���7�fw����P��&�c����{﹏E7-f�M�).���9��$F�f r �9'1��s2).��G��{���?,�
�G��p�µ�QU�UO�����>��/�g���,�M��5�ʖ�e˃�d����/�M`�=�y=�����f�ӫQU�k'��E�F�+ =΂���
l�&���%%�������F#KY����O7>��;w���l6***B�g)�#W�/�k2�������TJ�'����=!Q@mKYYYdg��$Ib��E�j6�U�,Z�鼌Uvv6YYYԶ��}( ���ߠ#x~�s,X0�����rY��yz�	|r�6l����cN��5ϑ��KBB���5ϡ#xq�7�`=4A�o�xds)�~wO�z�^��m���n�Ds�������e|�0�u��k�ٱ:��RN��w�/!�^�<�ͣ�K1d�F����:�������ˣ����%U�Ą������l{�y����)<�G�y�`}�t��y!��O@� A� Y��sv:K�J��ՎۣQ�܃��T6y�ǯ�Zi
��<�F��1>�	c#�Ǉ��i�L��D�� �u�awe1�e&')�_�Ǝ^V�i߀4�$G�:��r��>h�hݝ������t;)�� &�@zl�Ұր��V6�T�+����0q��L���[t���N&e��Z��ˆ/����(�i啝'i�R�����?:
P].L��S��E�݅�Á�.a6�WjY$F�9P�«����V^7���1Ȓ� �b6�(����0"�k�;�@MC���N�]7 �)Q|s����QfdI���5 ��.f��#1���G���z���>)�N�>�L0T�ۘ5}��Y[�W뿼mj���n���S?�v��ْ|.FE"=�ߑ��q����������p����3�¬8�T�GZ���4ݪ�0�L�Y��jRH��.X�&�v����#�t��7y_#�[�o��V�O����^�����paV�&J�V+V��QY����f+m��(�?/������{�X��:�!:5�G�x���I����HG�%�/�LZ\8/����yLf�Æ>�X�Єǣq���$E������E�Ǣ�����gێ��s�rxO��x孏Q]n���LH����98�i�0==���O$5��o^����>6�a� �*�)?^Ca��yv&���%�5>�n�bŜL:��y�w���/��o�褨A���y,[|=1�VZ�U>,?͑���w��u5d�#�K�b�D�&�:�����l~�S\���[CrTV�$����y��;#�������6�y��3ݸ5��.�V��K���{�,-ւ� k1aB���x���	LL� ����ңl۱������!U��0L�ϴ��O\t$Yi�D�Dm��]|�m���M�3���bT�
�N_����~uiIc��M�DZI���Wgkn����C��!xSv�Pt�F��kڨ��������OKh��L����Z&ip��
ޅ���U�C�[�6��p���;uW8<n'n��nͽQ�
�gԞ�+Z	���{���G�Ĭ� �t�]�p;躆 ��.�ۣ�������^��n�ut�L �W��+ ���hO��^�w�\i� ��:9>3�=��So�2v���U1z��.�^�ߋěN���,���� �f��V�    IEND�B`�           [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
[remap]

path="res://Viewport.gdc"
             �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx��ytTU��?�ի%���@ȞY1JZ �iA�i�[P��e��c;�.`Ow+4�>�(}z�EF�Dm�:�h��IHHB�BR!{%�Zߛ?��	U�T�
���:��]~�������-�	Ì�{q*�h$e-
�)��'�d�b(��.�B�6��J�ĩ=;���Cv�j��E~Z��+��CQ�AA�����;�.�	�^P	���ARkUjQ�b�,#;�8�6��P~,� �0�h%*QzE� �"��T��
�=1p:lX�Pd�Y���(:g����kZx ��A���띊3G�Di� !�6����A҆ @�$JkD�$��/�nYE��< Q���<]V�5O!���>2<��f��8�I��8��f:a�|+�/�l9�DEp�-�t]9)C�o��M~�k��tw�r������w��|r�Ξ�	�S�)^� ��c�eg$�vE17ϟ�(�|���Ѧ*����
����^���uD�̴D����h�����R��O�bv�Y����j^�SN֝
������PP���������Y>����&�P��.3+�$��ݷ�����{n����_5c�99�fbסF&�k�mv���bN�T���F���A�9�
(.�'*"��[��c�{ԛmNު8���3�~V� az
�沵�f�sD��&+[���ke3o>r��������T�]����* ���f�~nX�Ȉ���w+�G���F�,U�� D�Դ0赍�!�B�q�c�(
ܱ��f�yT�:��1�� +����C|��-�T��D�M��\|�K�j��<yJ, ����n��1.FZ�d$I0݀8]��Jn_� ���j~����ցV���������1@M�)`F�BM����^x�>
����`��I�˿��wΛ	����W[�����v��E�����u��~��{R�(����3���������y����C��!��nHe�T�Z�����K�P`ǁF´�nH啝���=>id,�>�GW-糓F������m<P8�{o[D����w�Q��=N}�!+�����-�<{[���������w�u�L�����4�����Uc�s��F�륟��c�g�u�s��N��lu���}ן($D��ת8m�Q�V	l�;��(��ڌ���k�
s\��JDIͦOzp��مh����T���IDI���W�Iǧ�X���g��O��a�\:���>����g���%|����i)	�v��]u.�^�:Gk��i)	>��T@k{'	=�������@a�$zZ�;}�󩀒��T�6�Xq&1aWO�,&L�cřT�4P���g[�
p�2��~;� ��Ҭ�29�xri� ��?��)��_��@s[��^�ܴhnɝ4&'
��NanZ4��^Js[ǘ��2���x?Oܷ�$��3�$r����Q��1@�����~��Y�Qܑ�Hjl(}�v�4vSr�iT�1���f������(���A�ᥕ�$� X,�3'�0s����×ƺk~2~'�[�ё�&F�8{2O�y�n�-`^/FPB�?.�N�AO]]�� �n]β[�SR�kN%;>�k��5������]8������=p����Ցh������`}�
�J�8-��ʺ����� �fl˫[8�?E9q�2&������p��<�r�8x� [^݂��2�X��z�V+7N����V@j�A����hl��/+/'5�3�?;9
�(�Ef'Gyҍ���̣�h4RSS� ����������j�Z��jI��x��dE-y�a�X�/�����:��� +k�� �"˖/���+`��],[��UVV4u��P �˻�AA`��)*ZB\\��9lܸ�]{N��礑]6�Hnnqqq-a��Qxy�7�`=8A�Sm&�Q�����u�0hsPz����yJt�[�>�/ޫ�il�����.��ǳ���9��
_
��<s���wT�S������;F����-{k�����T�Z^���z�!t�۰؝^�^*���؝c
���;��7]h^
��PA��+@��gA*+�K��ˌ�)S�1��(Ե��ǯ�h����õ�M�`��p�cC�T")�z�j�w��V��@��D��N�^M\����m�zY��C�Ҙ�I����N�Ϭ��{�9�)����o���C���h�����ʆ.��׏(�ҫ���@�Tf%yZt���wg�4s�]f�q뗣�ǆi�l�⵲3t��I���O��v;Z�g��l��l��kAJѩU^wj�(��������{���)�9�T���KrE�V!�D���aw���x[�I��tZ�0Y �%E�͹���n�G�P�"5FӨ��M�K�!>R���$�.x����h=gϝ�K&@-F��=}�=�����5���s �CFwa���8��u?_����D#���x:R!5&��_�]���*�O��;�)Ȉ�@�g�����ou�Q�v���J�G�6�P�������7��-���	պ^#�C�S��[]3��1���IY��.Ȉ!6\K�:��?9�Ev��S]�l;��?/� ��5�p�X��f�1�;5�S�ye��Ƅ���,Da�>�� O.�AJL(���pL�C5ij޿hBƾ���ڎ�)s��9$D�p���I��e�,ə�+;?�t��v�p�-��&����	V���x���yuo-G&8->�xt�t������Rv��Y�4ZnT�4P]�HA�4�a�T�ǅ1`u\�,���hZ����S������o翿���{�릨ZRq��Y��fat�[����[z9��4�U�V��Anb$Kg������]������8�M0(WeU�H�\n_��¹�C�F�F�}����8d�N��.��]���u�,%Z�F-���E�'����q�L�\������=H�W'�L{�BP0Z���Y�̞���DE��I�N7���c��S���7�Xm�/`�	�+`����X_��KI��^��F\�aD�����~�+M����ㅤ��	SY��/�.�`���:�9Q�c �38K�j�0Y�D�8����W;ܲ�pTt��6P,� Nǵ��Æ�:(���&�N�/ X��i%�?�_P	�n�F�.^�G�E���鬫>?���"@v�2���A~�aԹ_[P, n��N������_rƢ��    IEND�B`�       ECFG      _global_script_classes             _global_script_class_icons             application/config/name         texture_size_bug   application/run/main_scene         res://Node2D.tscn      application/config/icon         res://icon.png     display/window/size/width            display/window/size/height      �  )   rendering/environment/default_environment          res://default_env.tres          