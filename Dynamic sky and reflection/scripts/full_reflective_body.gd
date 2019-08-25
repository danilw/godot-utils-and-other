extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")

var is_rot=true;

func rotate_check():
	is_rot=!is_rot;

func set_visible_obj(idx):
	global_v.get_node("full_refl").get_child(idx).visible=true
	idx=(idx+1)%3
	global_v.get_node("full_refl").get_child(idx).visible=false
	idx=(idx+1)%3
	global_v.get_node("full_refl").get_child(idx).visible=false

func _ready():
	for a in global_v.get_node("viewports").get_child_count():
		global_v.get_node("viewports").get_child(a).get_child(0).environment=load("res://default_env.tres") as Environment
	pass

func _process(delta):
	if is_rot:
		for a in range(3):
			global_v.get_node("full_refl").get_child(a).rotate_z(-0.003)
			global_v.get_node("full_refl").get_child(a).rotate_y(-0.01)