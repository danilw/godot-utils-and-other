extends MeshInstance

onready var global_v=get_tree().get_root().get_node("scene")
onready var sky_b=get_tree().get_root().get_node("scene/Sky")

func _ready():
	var iChannel=sky_b.get_viewport().get_texture()
	iChannel.flags=Texture.FLAG_FILTER
	self.get_surface_material(0).set("shader_param/tex_panorama",iChannel)
	pass

func _process(delta):
	self.rotate_z(0.001)
	self.rotate_y(0.002)
