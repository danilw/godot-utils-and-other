extends FutariParticles

onready var floor_l=get_node("../../../../scene/floor_anix/left_f")
onready var mi=get_node("../MeshInstance/StaticBody")
onready var self_obj=get_node("../")

var last_pause=false
var pause_c_state=false
var local_time=0.0
var idx=0
var rand_state=0.0
var isalive=true

var full_time=180

#logic same as for vertex shader

func _ready():
	randomize()
	idx=self_obj.name.substr(3,2).to_int()
	local_time=idx
	self_obj.set_visible(true)
	rand_state=randf()
	self.emitting=false
	self_obj.translation=Vector3(17.5*(sin(2.0*PI*(local_time/48.0))),0,44+(4.0+8+8*sin(2.0*PI*(local_time/48.0))+14.0*smoothstep(full_time,0,local_time))*(idx%5))

func hide_colliders():
	if(last_pause!=get_tree().paused):
		if(get_tree().paused):
			pause_c_state=mi.get_child(0).disabled
			hide_colliders_on_rc()
		else:
			for a in range(mi.get_child_count()):
				mi.get_child(a).set_disabled(pause_c_state)

onready var pause_camera=get_node("../../../pause_camera")

func unfree():
	#-7, 48
	if((pause_camera.dex)&&(isalive)):
		isalive=false
		hide_colliders_on_rc()
	if((self_obj.translation.z<-1)):
		hide_it()
	if((self_obj.translation.z<-7)):
		self_obj.translation=Vector3(17.5*sin(2.0*PI*(local_time/48.0)),0,44+(4.0+8+8*sin(2.0*PI*(local_time/48.0))+14.0*smoothstep(full_time,0,local_time))*(idx%5))
		rand_state=randf()
		isalive=true
		show_colliders_on_rc()
		hide_it()
	if((self_obj.translation.z>44)):
		isalive=true
		show_colliders_on_rc()
		hide_it()
	if((self_obj.translation.z<38)&&(self_obj.translation.z>-1)):
		show_it()

func hide_colliders_on_rc():
	for a in range(mi.get_child_count()):
		mi.get_child(a).set_disabled(true)

func show_colliders_on_rc():
	for a in range(mi.get_child_count()):
		mi.get_child(a).set_disabled(false)

func show_it():
	#self_obj.set_visible(true)
	if(isalive):
		self.emitting=true
	if((!isalive)&&(pause_camera.dex)):
		if(pause_camera.dex_timer>3.0):
			self.emitting=false
	
func hide_it():
	#self_obj.set_visible(false)
	self.emitting=false

func move_n_(delta):
	if(!get_tree().paused):
		self_obj.translation.z+=-(0.8+1.5*smoothstep(0,full_time,local_time))*(01.0+2.0*rand_state)*delta

func _process(delta):
	hide_colliders()
	unfree()
	move_n_(delta)
	if(!get_tree().paused):
		local_time+=delta
	last_pause=get_tree().paused
	if((self.get_speed_scale()<1.0)&&(!get_tree().paused)):
		self.set_speed_scale(floor_l.get_speed_scale())
	if((get_tree().paused)&&(self.get_speed_scale()>0.001)):
		self.set_speed_scale(floor_l.get_speed_scale())
