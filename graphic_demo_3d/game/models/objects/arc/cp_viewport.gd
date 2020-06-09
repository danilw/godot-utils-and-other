extends Viewport

func _ready():
	get_node("../viewport").get_node("Sprite").material.set("shader_param/iChannel0",
	self.get_texture())
