extends Sprite

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	pass

func _process(delta):
	self.material.set("shader_param/iTime",global_v.iTime)
	self.material.set("shader_param/iFrame",global_v.iFrame)

