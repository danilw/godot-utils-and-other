extends Spatial

func _ready():
	var iTexture=get_node("../p0").get_viewport().get_texture()
	var cnode=get_node("../p1/p1/portals/a/wall/door_in")
	cnode.material_override.set("shader_param/fbo_texture",iTexture)
	cnode=get_node("../p2/p2/portals/a/wall/door_in")
	cnode.material_override.set("shader_param/fbo_texture",iTexture)
	cnode=get_node("../p3/p3/portals/a/wall/door_in")
	cnode.material_override.set("shader_param/fbo_texture",iTexture)
	cnode=get_node("../p4/p4/portals/a/wall/door_in")
	cnode.material_override.set("shader_param/fbo_texture",iTexture)
	cnode=get_node("../p5/p5/portals/a/wall/door_in")
	cnode.material_override.set("shader_param/fbo_texture",iTexture)

