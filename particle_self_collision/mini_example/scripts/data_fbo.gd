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
	self.material.set("shader_param/update_id",global_v.update_id)
	self.material.set("shader_param/update_type",global_v.update_type)
	self.material.set("shader_param/update_once",global_v.update_once)
	self.material.set("shader_param/rem_once",global_v.rem_once)
	self.material.set("shader_param/last_index",global_v.last_created_index)
	self.material.set("shader_param/spawn1",global_v.spawn1)
	self.material.set("shader_param/spawn2",global_v.spawn2)

