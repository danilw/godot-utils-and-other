extends Sprite

#udate uniforms

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	pass

func _process(delta):
	self.material.set("shader_param/iTime",global_v.iTime)
	self.material.set("shader_param/iFrame",global_v.iFrame)

func cov_scb(value):
	self.material.set("shader_param/COVERAGE",float(value)/100)

func absb_scb(value):
	self.material.set("shader_param/ABSORPTION",float(value)/10)

func thick_scb(value):
	self.material.set("shader_param/THICKNESS",value)

func step_scb(value):
	self.material.set("shader_param/STEPS",value)
