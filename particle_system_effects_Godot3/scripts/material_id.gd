extends Viewport

onready var global_v=get_tree().get_root().get_node("scene")
var old_res=Vector2()
var scale=1.0

func _ready():
	old_res=global_v.iResolution
	self.size=old_res*scale


func _process(delta):
	if((old_res.x!=global_v.iResolution.x)||(old_res.y!=global_v.iResolution.y)):
		old_res=global_v.iResolution
		self.size=old_res*scale


func _on_mid_select_item_selected(index):
	match(index):
		0:
			scale=0.25
			global_v.depth_step=0.0125
		1:
			scale=0.5
			global_v.depth_step=0.01
		2:
			scale=0.75
			global_v.depth_step=0.008
		3:
			scale=1.0
			global_v.depth_step=0.001
	self.size=old_res*scale
	get_node("../Camera/mid_debug").material_override.set_shader_param("depth_step", global_v.depth_step)
