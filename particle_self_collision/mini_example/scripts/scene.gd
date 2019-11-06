extends Node2D

# Building:
# to make it work you need rebuild(recompile) godot with adding GL_RGBA32F support
# edit source code files (lines base on godot-3.1.1-stable source version)
# 1. file drivers/gles3/rasterizer_storage_gles3.cpp line 6856
# else from this if (rt->flags[RENDER_TARGET_NO_3D_EFFECTS] && !rt->flags[RENDER_TARGET_TRANSPARENT])....
# change to this (replacing GL_RGBA16F etc)
#	else {
#		color_internal_format = GL_RGBA32F;
#		color_format = GL_RGBA;
#		color_type = GL_FLOAT;
#		image_format = Image::FORMAT_RGBAF;
#	}
# 2. file drivers/gles3/shaders/canvas.glsl
# everything(lowp and meduim) to highp

# logic limitations:
# 1. speed of falling particles has its limit,
# if you need speed it up only option is create more viewports
# 2. particle ID set on creation, changing particle variables(status(alive dead) or its HP etc)
# doable ONLY from outside of particle shader(iChannel0.shader), for this example
# particle can not change self status "on collision" or on hit some positon (like fire zone)
# (particle can store self-reaction status only in self pixel, so its only iChannel0 FBO)
# editing logic of iChannel0.shader to store some extra data with particle ID will make extra-data work (now use 0xffffff value to save id, cut some *f-s to save some you need there)
# 3. number of particles is limited (==FBO resolution x*y)
# 4. there absolutly no way(no way make it cheap real time) to sort/track dead and alive IDs
# this why new particles ID added to LAST, does not matter if some particles is "dead"(removed) already
# and only way to reset ID its clean all-FBO
# you can add same ID many times, like ID=1 for all particles, it does not matter for logic
# creating many particles with same ID allow to control "groups" in single ID data-value

# full page about HOW IT WORK read on this link <LINK>


var iTime=0.0
var iFrame=0
var clean_scr=false
var clean_scr5=false
var clean_scr10=false
var update_once=false
var spawn1=false
var spawn2=false
var update_id=0
var update_type=0
var rem_once=false
var zoom_v=0.33
const gravity_max=0.006
var gravity=Vector2(0.0, 0.003)
var iMouse=Vector3() 
var iResolution=Vector2(1280,720)
var scr_posx=0.5
var scr_posy=0.85
var speed=1.0
var last_created_index=108800-1

# (340 is H in shader) (res.x*H/2.)/2. (particles on each second pixel on x, and every second on y
var part_total=(340*640/2)/2
const p_max=230400 #640*360

func _ready():
	pass

func upd_imouse():
	var m_pos=get_viewport().get_mouse_position()/iResolution
	m_pos.x=clamp(m_pos.x,0,1)
	m_pos.y=clamp(m_pos.y,0,1)
	iMouse=Vector3(m_pos.x*iResolution.x,iResolution.y*m_pos.y,0)
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		if(iMouse.x>30)&&(iMouse.y<690)&&(iMouse.y>35):
			iMouse.z=1
			if(spawn1&&(iFrame%3==0)):
				last_created_index+=1
				part_total+=1
			if(spawn2&&(iFrame%3==0)):
				last_created_index+=7 #should be 6-8
				part_total+=7
			part_total=min(part_total,p_max)
		

func _process(delta):
	iTime+=delta
	iFrame+=1
	upd_imouse()



