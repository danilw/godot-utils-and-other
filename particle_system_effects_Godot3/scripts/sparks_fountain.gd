extends Particles

onready var camnode=get_node("../../Camera")

func _ready():
	pass

var iTime=0

func _process(delta):
	iTime+=delta

	material_override.set("shader_param/cam_pos",camnode.translation)
	material_override.set("shader_param/iTime",iTime)
