extends MeshInstance

func _ready():
	pass

onready var post_p=get_tree().get_root().get_node("scene/main_screen")
var ctime=0

func _process(delta):
	self.material_override.set("shader_param/iTime",post_p.iTime-ctime)
	pass
