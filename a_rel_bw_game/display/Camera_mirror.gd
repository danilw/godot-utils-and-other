extends Camera

onready var main_camera=get_tree().get_root().get_node("scene/main_screen/main_vp/").get_viewport().get_camera()

func _ready():
	pass

var passff=true
func _process(delta):
	if(passff):
		passff=false
		return
	self.rotation=main_camera.rotation
	pass
