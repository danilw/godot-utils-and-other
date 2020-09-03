extends Spatial

onready var p1=get_node("portal/p1")

func _ready():
	pass

var iTime=0

func _process(delta):
	iTime+=delta
	p1.material_override.set("shader_param/iTime",iTime)
