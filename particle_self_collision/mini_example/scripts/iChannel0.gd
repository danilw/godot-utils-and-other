extends Sprite

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	pass

func _process(delta):
	self.material.set("shader_param/iTime",global_v.iTime)
	self.material.set("shader_param/iFrame",global_v.iFrame)
	self.material.set("shader_param/iMouse",global_v.iMouse)
	self.material.set("shader_param/clean_scr",global_v.clean_scr)
	self.material.set("shader_param/clean_scr5",global_v.clean_scr5)
	self.material.set("shader_param/clean_scr10",global_v.clean_scr10)
	self.material.set("shader_param/gravity",global_v.gravity)
	self.material.set("shader_param/scale_v",global_v.zoom_v)
	self.material.set("shader_param/scr_posx",global_v.scr_posx)
	self.material.set("shader_param/scr_posy",global_v.scr_posy)
	self.material.set("shader_param/speed_x",global_v.speed)
	self.material.set("shader_param/last_index",global_v.last_created_index)
	self.material.set("shader_param/spawn1",global_v.spawn1)
	self.material.set("shader_param/spawn2",global_v.spawn2)
	

