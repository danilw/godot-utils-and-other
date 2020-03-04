extends MeshInstance

func _ready():
	pass

func _process(delta):
	self.material_override.set("shader_param/light_pos",get_node("../").translation-get_node("../../shadow_map").translation)
