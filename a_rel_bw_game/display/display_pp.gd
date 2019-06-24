extends ViewportContainer

#udate uniforms

var iTime=0.0
var iFrame=0
var conf_click=-10.0
var play_click=0.0
var ppoff=false
var disable_refl=false
var disable_panorama=false
var ispause=true

func _ready():
	get_tree().paused=true
	pass

onready var gui_c=get_tree().get_root().get_node("scene/gui_c/vp/gui")

func _input(event):
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		gui_c._on_Ok_pressed()

func _process(delta):
	self.material.set("shader_param/iTime",iTime)
	self.material.set("shader_param/conf_click",conf_click)
	self.material.set("shader_param/play_click",play_click)
	self.material.set("shader_param/iFrame",iFrame)
	self.material.set("shader_param/ppoff",ppoff)
	iTime+=delta
	iFrame+=1
