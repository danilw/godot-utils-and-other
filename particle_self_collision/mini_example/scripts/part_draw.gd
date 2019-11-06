extends Particles2D

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	self.emitting=true

func _process(delta):
	self.material.set("shader_param/iTime",global_v.iTime)
	self.material.set("shader_param/iFrame",global_v.iFrame)
	self.material.set("shader_param/iMouse",global_v.iMouse)
	self.material.set("shader_param/scale_v",global_v.zoom_v)
	
	self.process_material.set("shader_param/iTime",global_v.iTime)
	self.process_material.set("shader_param/iFrame",global_v.iFrame)
	self.process_material.set("shader_param/iMouse",global_v.iMouse)
	self.process_material.set("shader_param/scale_v",global_v.zoom_v)
	self.process_material.set("shader_param/scr_posx",global_v.scr_posx)
	self.process_material.set("shader_param/scr_posy",global_v.scr_posy)