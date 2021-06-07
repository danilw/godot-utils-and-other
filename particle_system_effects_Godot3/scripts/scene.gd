extends Spatial


# self https://danilw.itch.io/particle-effects-godot3
# self https://github.com/danilw/godot-utils-and-other

# WARNING Nvidia has bug with some shaders https://github.com/danilw/godot-utils-and-other/issues/6
# if this project crash for you then edit (outside of Godot) 
# (just copy there any other shader code that works)
# shaders/particle_cube_base.shader
# shaders/demo/particle_cube_audio.shader
# shaders/demo/particle_cube_spiral.shader


#  In this project used CC-non commercial 3D models from sketchfab
# all used resources
# https://github.com/danilw/godot-utils-and-other/blob/master/particle_system_effects_Godot3/USED_RESOURCES_LINKS.md

# Used music from
# https://patrickdearteaga.com/


# Main License:
# All shader-logic and other my-own graphic and logic under MIT-license.


# about SOUND texture:
# it correct!

# AVOID THIS MISTAKE:

# in importing audio texture as sampler2D write this :
# uniform sampler2D iChannel0;

# DO NOT use any "hint_" like uniform sampler2D iChannel0:hint_black; or like that
# "hint_" means Godot do SRGB trnaslation BEFORE shader reads texture, srgb ruin audio texture



var iTime=0.0
var iFrame=0
var FPS_counter=1.0

var iMouse=Vector2(0,0) #mouse xy
var iMouse_press=Vector2(0,0) #mouse pressed xy
var iMouse_d=Vector2(0,0) #mouse press
var iMouse_3d=Vector3() #camera mouse
var iMouse_3d_normal=Vector3() #camera mouse
var iResolution=Vector2(1280,720) #to fix godot viewport rescale

var iMouse_mid=-1 #material ID under mouse
var depth_step=0.001

var pleload_once=false
var pleload_done=false
var preload_time=0.0


func _ready():
	randomize()

func _process(delta):
	iResolution=get_viewport().size
	var m_pos=get_viewport().get_mouse_position()/iResolution
	iMouse=Vector2(m_pos.x*iResolution.x,iResolution.y*(1.0-m_pos.y))
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		iMouse_press=iMouse
	
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		iMouse_d.x=min(iMouse_d.x+delta,1.0)
	else:
		iMouse_d.x=max(iMouse_d.x-delta,0.0)
		
	if(Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		iMouse_d.y=min(iMouse_d.y+delta,1.0)
	else:
		iMouse_d.y=max(iMouse_d.y-delta,0.0)
	
	FPS_counter=1.0/max(delta,0.0001)
	FPS_counter=max(FPS_counter,1.0)
	if(!get_tree().paused):
		iTime+=delta
		iFrame+=1
	if(pleload_once):
		pleload_once=false
		pleload_done=true
		iTime=iTime-preload_time
