extends MeshInstance

onready var global_v=get_node("../../scene")
onready var post_p=get_tree().get_root().get_node("scene/main_screen")
onready var sky_b=get_tree().get_root().get_node("scene/Sky")

func _ready():
	global_v.iChannel_panorama=sky_b.get_viewport().get_texture()
	global_v.iChannel_panorama.flags=Texture.FLAG_FILTER
	self.get_surface_material(0).set("shader_param/tex_panorama",global_v.iChannel_panorama)

func _physics_process(delta):
	pass

func _process(delta):
	self.get_surface_material(0).set("shader_param/minif",global_v.conf_clicked)
	self.get_surface_material(0).set("shader_param/disable_panorama",post_p.disable_panorama)
	if(post_p.ispause):
		self.get_surface_material(0).set("shader_param/disable_refl",true)
	else:
		self.get_surface_material(0).set("shader_param/disable_refl",post_p.disable_refl)
