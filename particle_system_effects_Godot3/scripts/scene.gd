extends Spatial

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
