extends Particles

onready var global_v=get_node("../../../scene")
onready var post_p=get_tree().get_root().get_node("scene/main_screen")

func _ready():
	self.material_override.set("shader_param/tex_panorama",global_v.iChannel_panorama)
	pass

func _process(delta):
	self.material_override.set("shader_param/disable_panorama",post_p.disable_panorama)
	self.process_material.set("shader_param/iTime",global_v.iTime)
	self.material_override.set("shader_param/iTime",global_v.iTime)